#!/usr/bin/perl -w  


use Tk;
use Tree::Trie;
use strict;
use warnings;

#variable
my $dictionary = new Tree::Trie;
my @suggestion;
my $filename = "dictionary.txt";
my $projectname = "smart text editor";
#load dictionary
open my $fh, '<', $filename or die $!;
while(<$fh>){
	my $row = $_;
	chomp $row;
	$dictionary->add($row);
}
print $filename," load succeed!\n";#testing
close $fh or die $!;
#create window
my $mw = MainWindow->new;
#input field
my $input_field = $mw->Entry;
my $text_field = $mw->Text;
#listbox
my $selectable = $mw->Listbox;
#buttons
#this button add new word to dictionary
my $button_new = $mw->Button(-text => 'new',-command => \&add_new);
#this button output edited text
my $button_output = $mw->Button(-text => 'output',-command => \&output);
#this function will create selectable boxes base on params
$selectable->insert('end',sort @suggestion);
#check every sec if input field is changed
my $isChange = $input_field->get;
$mw->repeat(
    1000,
    sub {
       if($isChange ne $input_field->get){#if changed
		print "text changed!\n";#testing
		$isChange = $input_field->get;
		$selectable->delete(0,'end');
		@suggestion = $dictionary->lookup($input_field->get);
		$selectable->insert('end',sort @suggestion);#new list
        } 
    },
);
#layout field
$mw->configure(-title=>$projectname);
$input_field->pack;
$text_field->pack;
$selectable->bind("<<ListboxSelect>>",\&SelText);
$selectable->pack;
$button_new->pack;
$button_output->pack;
#main & functions
MainLoop;
#add new word to dictionary
sub add_new{
	print "text ".$input_field->get." added!\n";#testing
	open my $fh, '>>', $filename or die $!;
	print $fh $input_field->get;
	$dictionary->add($input_field->get);
	close $fh or die $!;
}
#output text file
sub output{
	print "textfile created!\n";#testing
	my $outputfilename = $projectname.'_output';
	my $i = 1;
	while(-e $outputfilename){#find unuse filename
		$outputfilename = $projectname.'_output ('.$i.')';
		$i++;
	}
	open my $fh, '>', $outputfilename or die $!;
	print $fh $text_field->get('1.0','end-1c');
	close $fh or die $!;
}
#event for selectable
sub SelText{
	print $selectable->get($selectable->curselection)." clicked!\n";#testing
 	my $current_ip =  $selectable->get($selectable->curselection);
        $text_field->insert('end',$current_ip.' ');
}


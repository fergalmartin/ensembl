use lib 't';

BEGIN { $| = 1;  
	use Test;
	plan tests => 16;
}

my $loaded = 0;
END {print "not ok 1\n" unless $loaded;}

use EnsTestDB;
use Bio::EnsEMBL::DBLoader;



$loaded = 1;

ok(1);

# Database will be dropped when this
# object goes out of scope
my $ens_test = EnsTestDB->new;

$ens_test->do_sql_file("t/minidatabase.dump");

ok($ens_test);



my $db = $ens_test->get_DBSQL_Obj;
$cadp = $db->get_RawContigAdaptor();
$contig = $cadp->fetch_by_dbID(3);
my $analysis = $db->get_AnalysisAdaptor->fetch_by_newest_logic_name("dummy-gene");

ok($analysis);
ok($contig);


$gene_ad = $db->get_GeneAdaptor();


my $gene = Bio::EnsEMBL::Gene->new();

my $transcript1 = Bio::EnsEMBL::Transcript->new();
my $transcript2 = Bio::EnsEMBL::Transcript->new();

my $ex1 = Bio::EnsEMBL::Exon->new(); 
my $ex2 = Bio::EnsEMBL::Exon->new();
my $ex3 = Bio::EnsEMBL::Exon->new();

my $translation1 = Bio::EnsEMBL::Translation->new();
my $translation2 = Bio::EnsEMBL::Translation->new();	

ok($gene);


$ex1->start(5);
$ex1->end(10);
$ex1->phase(0);
$ex1->attach_seq($contig->primary_seq);
$ex1->contig_id($contig->dbID);
$ex1->strand(1);
$ex1->analysis($analysis);

$ex2->start(15);
$ex2->end(23);
$ex2->phase(0);
$ex2->attach_seq($contig->primary_seq);
$ex2->contig_id($contig->dbID);
$ex2->strand(1);
$ex2->analysis($analysis);

$ex3->start(28);
$ex3->end(33);
$ex3->phase(0);
$ex3->attach_seq($contig->primary_seq);
$ex3->contig_id($contig->dbID);
$ex3->strand(1);
$ex3->analysis($analysis);



$transcript1->add_Exon($ex1);
$transcript1->add_Exon($ex2);
$translation1->start_exon($ex1);
$translation1->end_exon($ex2);
$translation1->start(1);
$translation1->end(9);
$transcript1->translation($translation1);


ok($transcript1);

$transcript2->add_Exon($ex1);
$transcript2->add_Exon($ex2);
$transcript2->add_Exon($ex3);
$translation2->start_exon($ex1);
$translation2->end_exon($ex3);
$translation2->start(1);
$translation2->end(6);
$transcript2->translation($translation2);

ok($transcript2);


$gene->add_Transcript($transcript1);
$gene->add_Transcript($transcript2);

$gene->analysis($analysis);

my $count = 0;

foreach my $tr($gene->each_Transcript){
	
	foreach my $exon($tr->get_all_Exons){
	
	 $count++;
	
	}	

}



ok($count == 5);


ok(scalar($gene->get_all_Exons()) == 3);



$gene_ad->store($gene);



ok(1);

my @contig_ids = ($contig->name);

my @genes = $gene_ad->fetch_by_contig_list(@contig_ids);

ok(@genes);

my $gene_out = $genes[0];

ok(scalar($gene_out->get_all_Exons()) == 3);

my @exons = $gene_out->get_all_Exons();

@sorted_exons = sort{$a->start <=> $b->start}@exons;



ok($sorted_exons[0]->start==5);



ok($sorted_exons[1]->strand==1);



ok($sorted_exons[2]->phase==0);



my $pep;
my $translate = 0;
foreach my $trans($gene->each_Transcript()){
	
	my $pep = $trans->translate();

	if($pep !=~ /\*/){
	    $translate = 1;
        }else{
	 $translate = 0;
        }  	    

}

ok($translate == 1);

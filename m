Date: Mon, 28 Jul 2008 13:55:21 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: + mm-remove-find_max_pfn_with_active_regions.patch added to -mm
 tree
Message-Id: <20080728135521.12b1b041.akpm@linux-foundation.org>
In-Reply-To: <20080728203959.GA29548@csn.ul.ie>
References: <200807280313.m6S3DHDk017400@imap1.linux-foundation.org>
	<20080728091655.GC7965@csn.ul.ie>
	<86802c440807280415j5605822brb8836412a5c95825@mail.gmail.com>
	<20080728113836.GE7965@csn.ul.ie>
	<86802c440807281125g7d424f17v4b7c512929f45367@mail.gmail.com>
	<20080728191518.GA5352@csn.ul.ie>
	<86802c440807281238u63770318s8e665754f666c602@mail.gmail.com>
	<20080728200054.GB5352@csn.ul.ie>
	<86802c440807281314k56752cdcqcac542b6f1564036@mail.gmail.com>
	<20080728203959.GA29548@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: yhlu.kernel@gmail.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 28 Jul 2008 21:40:00 +0100
Mel Gorman <mel@csn.ul.ie> wrote:

> > how about KERN_DEBUG?
> > 
> > please check
> > 
> 
> Still NAK due to the noise.

blah.  I changed the patch to this:

--- a/include/linux/mm.h~mm-remove-find_max_pfn_with_active_regions
+++ a/include/linux/mm.h
@@ -1041,7 +1041,6 @@ extern unsigned long absent_pages_in_ran
 extern void get_pfn_range_for_nid(unsigned int nid,
 			unsigned long *start_pfn, unsigned long *end_pfn);
 extern unsigned long find_min_pfn_with_active_regions(void);
-extern unsigned long find_max_pfn_with_active_regions(void);
 extern void free_bootmem_with_active_regions(int nid,
 						unsigned long max_low_pfn);
 typedef int (*work_fn_t)(unsigned long, unsigned long, void *);
diff -puN mm/page_alloc.c~mm-remove-find_max_pfn_with_active_regions mm/page_alloc.c
--- a/mm/page_alloc.c~mm-remove-find_max_pfn_with_active_regions
+++ a/mm/page_alloc.c
@@ -3753,23 +3753,6 @@ unsigned long __init find_min_pfn_with_a
 	return find_min_pfn_for_node(MAX_NUMNODES);
 }
 
-/**
- * find_max_pfn_with_active_regions - Find the maximum PFN registered
- *
- * It returns the maximum PFN based on information provided via
- * add_active_range().
- */
-unsigned long __init find_max_pfn_with_active_regions(void)
-{
-	int i;
-	unsigned long max_pfn = 0;
-
-	for (i = 0; i < nr_nodemap_entries; i++)
-		max_pfn = max(max_pfn, early_node_map[i].end_pfn);
-
-	return max_pfn;
-}
-
 /*
  * early_calculate_totalpages()
  * Sum pages in active regions for movable zone.
_


Which is what it should always have been.  Only do one thing per patch,
please.  The presence of the work "also" in the changelog is usually a
big hint that it should be split up.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

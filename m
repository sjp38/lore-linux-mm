Date: Mon, 3 Sep 2001 08:14:40 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: [PATCH *] reverse mappings, version 3
Message-ID: <Pine.LNX.4.33L.0109030811350.10545-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

I just uploaded version 3 of the reverse mapping patch versus
2.4.8-ac12, this version has survived several hours of heavy
beating when booted with mem=8m and mem=12m as well as running
well with larger memory configurations (up to 128MB, my laptop
isn't any bigger).

This version is theoretically SMP safe and should be easy to
port to other architectures. SMP testing and support for other
architectures will be appreciated ;)))

	http://www.surriel.com/patches/2.4/2.4.8-ac12-pmap3

----

2.4.8-ac12-pmap3:
  o cleaned up pmap code to make porting to other architectures easy
  o start making the swap out path SMP safe (untested!)
      o try_to_swap_out() and page_remove_all_pmaps() turned into
        allocate_swap_space() and try_to_unmap()
  o make sure page_launder() skips pages on SWAP_FAIL
  o make refill_inactive() decide for itself how much to scan
  o mremap() now really removes the old pte_chains

2.4.8-ac12-pmap2:
  o fixed oops where 2 simultaneous do_wp_page()s would copy the same
    page together and then hand __free_pages_ok() a page still on the
    active list

2.4.8-ac12-pmap:
  o undo broken locking in exec.c
  o grab mm->page_table_lock before doing find_vma in try_to_swap_out()
  o add pages to active list on swapin, fixes leak
  o make sure page_referenced clears the referenced bit
  o fix inactive_target macro
  o first mostly working version ;)

Rik
-- 
IA64: a worthy successor to i860.

http://www.surriel.com/		http://distro.conectiva.com/

Send all your spam to aardvark@nl.linux.org (spam digging piggy)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 481906B004A
	for <linux-mm@kvack.org>; Sun, 24 Jul 2011 10:39:18 -0400 (EDT)
Received: from localhost (unknown [122.167.86.237])
	by mail.wnohang.net (Postfix) with ESMTPSA id A53D0F0003
	for <linux-mm@kvack.org>; Sun, 24 Jul 2011 10:39:14 -0400 (EDT)
Date: Sun, 24 Jul 2011 20:09:11 +0530
From: Raghavendra D Prabhu <rprabhu@wnohang.net>
Subject: Regarding find_get_pages{,_contig}
Message-ID: <20110724143708.GA5193@Xye>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

Hi mm,

     I was looking to use 

     find_get_pages (struct address_space *mapping, pgoff_t start, unsigned int nr_pages, struct page **pages) 

     and the comment in the code says -- "There may be holes in the
     indices due to not-present pages." I perceived this to be filling
     pages which are in the cache  and skipping the ones which are not
     present -- after the function returns, pages[i] to be not set (NULL
     when pages is from a kzalloc) if corresponding page at index i +
     offset is not in cache ie. a hole. 
     
     But from what I have seen, what it does is set pages[0..nr_in_cache]
     to pages found and rest pages[nr_in_cache + 1 .. nr_pages]  to be
     unset/NULL. By looking at the code, it is calling
     radix_tree_gang_lookup_slot, which again returns entries in a
     similar way and loops nr_found times (and not nr_pages times). I
     looked at the difference between find_get_pages and
     find_get_pages_contig, and the only difference I could spot is it
     increments index which is used only when a condition is true.

     So, does holes in indices mean something else or is there a
     different function which can be used for this ?
--------------------------
Raghavendra Prabhu
GPG Id : 0xD72BE977
Fingerprint: B93F EBCB 8E05 7039 CD3C A4B8 A616 DCA1 D72B E977
www: wnohang.net

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

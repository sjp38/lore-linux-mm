Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 952546B0073
	for <linux-mm@kvack.org>; Wed, 24 Oct 2012 22:00:35 -0400 (EDT)
Received: by mail-da0-f41.google.com with SMTP id i14so581580dad.14
        for <linux-mm@kvack.org>; Wed, 24 Oct 2012 19:00:34 -0700 (PDT)
Message-ID: <50889D37.2020908@gmail.com>
Date: Thu, 25 Oct 2012 10:00:23 +0800
From: Ni zhan Chen <nizhan.chen@gmail.com>
MIME-Version: 1.0
Subject: some ksm questions
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux Memory Management List <linux-mm@kvack.org>
Cc: Izik Eidus <izik.eidus@ravellosystems.com>, Andrea Arcangeli <aarcange@redhat.com>, Petr Holasek <pholasek@redhat.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Chris Wright <chrisw@sous-sol.org>

Hi all,

I have some detail questions about ksm. Thanks in adance.

1) Why judge if(page->mapping != expected_mapping) in function 
get_ksm_page called twice? And it also call put_page(page) in the second 
time, when this put_page associated get_page(page) is called?

2)
in function scan_get_next_rmap_itemi 1/4 ?
if (PageAnon(*page)) ||
page_trans_compound_anon(*page)) {
flush_anon_page(vma, *page, ksm_scan.address);
flush_dcache_page(*page);
rmap_item = get_next_rmap_item(slot,
a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??
why call flush_dcache_page here? in kernel doc 
Documentation/cachetlb.txt, it said that "Any time the kernel writes to 
a page cache page, _OR_ the kernel is about to read from a page cache 
page and user space shared/writable mappings of this page potentially 
exist, this routine is called", it is used for flush page cache related 
cpu cache, but ksmd only scan anonymous page.

3) in function remove_rmap_item_from_tree, how to understand formula age 
= (unsigned char) (ksm_scan.seqr - rmap_item->address); why need aging?

4) in function page_volatile_show, how to understand ksm_pages_volatile 
= ksm_rmap_items - ksm_pages_shared - ksm_pages_sharing - 
ksm_pages_unshared; I mean that how this formula can figure out "how 
many pages changing too fast to be placed in a tree"?

Regards,
Chen

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

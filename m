Date: Sat, 8 Apr 2000 16:44:14 -0700
Message-Id: <200004082344.QAA02536@pizda.ninka.net>
From: "David S. Miller" <davem@redhat.com>
In-reply-to: <200004082111.OAA73647@google.engr.sgi.com>
	(kanoj@google.engr.sgi.com)
Subject: Re: zap_page_range(): TLB flush race
References: <200004082111.OAA73647@google.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kanoj@google.engr.sgi.com
Cc: manfreds@colorfullife.com, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

   > filemap_sync() calls flush_tlb_page() for each page, but IMHO this is a
   > really bad idea, the performance will suck with multi-threaded apps on
   > SMP.

   The best you can do probably is a flush_tlb_range?

People, look at the callers of filemap_sync, it does range tlb/cache
flushes so the flushes in filemap_sync_pte() are in fact spurious.

Later,
David S. Miller
davem@redhat.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

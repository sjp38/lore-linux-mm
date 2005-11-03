Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e3.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id jA3Hn9bg006411
	for <linux-mm@kvack.org>; Thu, 3 Nov 2005 12:49:09 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id jA3Hn987120778
	for <linux-mm@kvack.org>; Thu, 3 Nov 2005 12:49:09 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11/8.13.3) with ESMTP id jA3Hn8Cb008461
	for <linux-mm@kvack.org>; Thu, 3 Nov 2005 12:49:09 -0500
Subject: Re: [Lhms-devel] [PATCH 0/7] Fragmentation Avoidance V19
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <Pine.LNX.4.64.0511030918110.27915@g5.osdl.org>
References: <4366C559.5090504@yahoo.com.au>
	 <Pine.LNX.4.58.0511010137020.29390@skynet><4366D469.2010202@yahoo.com.au>
	 <Pine.LNX.4.58.0511011014060.14884@skynet><20051101135651.GA8502@elte.hu>
	 <1130854224.14475.60.camel@localhost><20051101142959.GA9272@elte.hu>
	 <1130856555.14475.77.camel@localhost><20051101150142.GA10636@elte.hu>
	 <1130858580.14475.98.camel@localhost><20051102084946.GA3930@elte.hu>
	 <436880B8.1050207@yahoo.com.au><1130923969.15627.11.camel@localhost>
	 <43688B74.20002@yahoo.com.au><255360000.1130943722@[10.10.2.4]>
	 <4369824E.2020407@yahoo.com.au> <306020000.1131032193@[10.10.2.4]>
	 <1131032422.2839.8.camel@laptopd505.fenrus.org>
	 <Pine.LNX.4.64.0511030747450.27915@g5.osdl.org>
	 <Pine.LNX.4.58.0511031613560.3571@skynet>
	 <Pine.LNX.4.64.0511030842050.27915@g5.osdl.org>
	 <309420000.1131036740@[10.10.2.4]>
	 <Pine.LNX.4.64.0511030918110.27915@g5.osdl.org>
Content-Type: text/plain
Date: Thu, 03 Nov 2005 18:48:46 +0100
Message-Id: <1131040126.19901.54.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@osdl.org>
Cc: "Martin J. Bligh" <mbligh@mbligh.org>, Mel Gorman <mel@csn.ul.ie>, Arjan van de Ven <arjan@infradead.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@osdl.org>, kravetz@us.ibm.com, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, lhms <lhms-devel@lists.sourceforge.net>, Arjan van de Ven <arjanv@infradead.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2005-11-03 at 09:19 -0800, Linus Torvalds wrote:
> On Thu, 3 Nov 2005, Martin J. Bligh wrote:
> > 
> > The problem is how these zones get resized. Can we hotplug memory between 
> > them, with some sparsemem like indirection layer?
> 
> I think you should be able to add them. You can remove them. But you can't 
> resize them.

Any particular reasons you think we can't resize them?  I know shrinking
the non-reclaim (DMA,NORMAL) zones will be practically impossible, but
it should be quite possible to shrink the reclaim zone, and grow DMA or
NORMAL into it.

This will likely be necessary as memory is added to a system, and the
ratio of reclaim to non-reclaim zones gets out of whack and away from
the magic 16:1 or 8:1 highmem:normal ratio that seems popular.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

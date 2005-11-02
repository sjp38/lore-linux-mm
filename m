Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id jA2Ch32q003291
	for <linux-mm@kvack.org>; Wed, 2 Nov 2005 07:43:03 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id jA2Ch3Vi116996
	for <linux-mm@kvack.org>; Wed, 2 Nov 2005 07:43:03 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.13.3) with ESMTP id jA2Ch2SO006613
	for <linux-mm@kvack.org>; Wed, 2 Nov 2005 07:43:03 -0500
Subject: Re: [Lhms-devel] [PATCH 0/7] Fragmentation Avoidance V19
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20051102120048.GA10081@elte.hu>
References: <20051102104131.GA7780@elte.hu>
	 <E1EXGPs-0006JA-00@w-gerrit.beaverton.ibm.com>
	 <20051102120048.GA10081@elte.hu>
Content-Type: text/plain
Date: Wed, 02 Nov 2005 13:42:49 +0100
Message-Id: <1130935369.15627.37.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Gerrit Huizenga <gh@us.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <nickpiggin@yahoo.com.au>, "Martin J. Bligh" <mbligh@mbligh.org>, Andrew Morton <akpm@osdl.org>, kravetz@us.ibm.com, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, lhms <lhms-devel@lists.sourceforge.net>
List-ID: <linux-mm.kvack.org>

On Wed, 2005-11-02 at 13:00 +0100, Ingo Molnar wrote:
> 
> >  Yeah - and that isn't what is being proposed here.  The goal is to 
> >  ask the kernel to identify some memory which can be legitimately 
> >  freed and hasten the freeing of that memory.
> 
> but that's very easy to identify: check the free list or the clean 
> list(s). No defragmentation necessary. [unless the unit of RAM mapping 
> between hypervisor and guest is too coarse (i.e. not 4K pages).]

It needs to be that coarse in cases where HugeTLB is desired for use.
I'm not sure I could convince the DB guys to give up large pages,
they're pretty hooked on them. ;)

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

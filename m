Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e36.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id j9I8kMiM009844
	for <linux-mm@kvack.org>; Tue, 18 Oct 2005 04:46:22 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j9I8mvTB547590
	for <linux-mm@kvack.org>; Tue, 18 Oct 2005 02:48:57 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j9I8m3Bi019864
	for <linux-mm@kvack.org>; Tue, 18 Oct 2005 02:48:04 -0600
Message-ID: <4354B6CD.20907@de.ibm.com>
Date: Tue, 18 Oct 2005 10:48:13 +0200
From: Carsten Otte <cotte@de.ibm.com>
Reply-To: carsteno@de.ibm.com
MIME-Version: 1.0
Subject: Re: [Patch 2/3] Export get_one_pte_map.
References: <20051014192111.GB14418@lnx-holt.americas.sgi.com>	<20051014192225.GD14418@lnx-holt.americas.sgi.com>	<20051014213038.GA7450@kroah.com>	<20051017113131.GA30898@lnx-holt.americas.sgi.com>	<1129549312.32658.32.camel@localhost>	<20051017114730.GC30898@lnx-holt.americas.sgi.com>	<Pine.LNX.4.61.0510171331090.2993@goblin.wat.veritas.com>	<20051017151430.GA2564@lnx-holt.americas.sgi.com>	<20051017152034.GA32286@kroah.com>	<20051017155605.GB2564@lnx-holt.americas.sgi.com>	<Pine.LNX.4.61.0510171700150.4934@goblin.wat.veritas.com> <20051017135314.3a59fb17.akpm@osdl.org>
In-Reply-To: <20051017135314.3a59fb17.akpm@osdl.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Hugh Dickins <hugh@veritas.com>, holt@sgi.com, greg@kroah.com, haveblue@us.ibm.com, linux-ia64@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, hch@infradead.org, jgarzik@pobox.com, wli@holomorphy.com, nickpiggin@yahoo.com.au, steiner@americas.sgi.com, mschwid2@de.ibm.com
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> Ther are nearly 100 mm patches in -mm.  I need to do a round of discussion
> with the originators to work out what's suitable for 2.6.15.  For "Hugh
> stuff" I'm thinking maybe the first batch
> (mm-hugetlb-truncation-fixes.patch to mm-m68k-kill-stram-swap.patch) and
> not the second batch.  But we need to think about it.
We tested Hugh's stuff that is currently in -mm, mainly from the xip
perspecive. Seems to work fine for 390.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id D9ADC6B0170
	for <linux-mm@kvack.org>; Thu, 14 Oct 2010 11:10:11 -0400 (EDT)
Date: Fri, 15 Oct 2010 00:09:47 +0900
Subject: Re: [RFC][PATCH 1/3] contigous big page allocator
From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
In-Reply-To: <20101014125519.GB13414@basil.fritz.box>
References: <20101014072421.GA13414@basil.fritz.box>
	<20101014173103U.fujita.tomonori@lab.ntt.co.jp>
	<20101014125519.GB13414@basil.fritz.box>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-Id: <20101015000416N.fujita.tomonori@lab.ntt.co.jp>
Sender: owner-linux-mm@kvack.org
To: andi@firstfloor.org
Cc: fujita.tomonori@lab.ntt.co.jp, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, minchan.kim@gmail.com
List-ID: <linux-mm.kvack.org>

On Thu, 14 Oct 2010 14:55:19 +0200
Andi Kleen <andi@firstfloor.org> wrote:

> > I think that at least one mainline driver in arm uses such trick but I
> > can't recall the name. Better to ask on the arm mainling list. Also I
> > heard that the are some out-of-tree patches about this.
> 
> I'm sure there are out of tree patches for lots of things,
> but at least in terms of merging mainline functionality
> use cases merged in the mainline tree are required.

I think that we already have drivers that need such feature in
mainline. They keep out-of-tree patches that give continuous memory to
these drivers reliably.

Anyway, Felipe pointed out one user. I also think that
drivers/media/video/videobuf-dma-contig.c also was already mentioned,
needs such feature.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

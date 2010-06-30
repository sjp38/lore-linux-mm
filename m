Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id BB18D6B01AC
	for <linux-mm@kvack.org>; Tue, 29 Jun 2010 20:31:10 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o5U0V5qU001506
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 30 Jun 2010 09:31:06 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9295645DE6E
	for <linux-mm@kvack.org>; Wed, 30 Jun 2010 09:31:05 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6C5D545DE60
	for <linux-mm@kvack.org>; Wed, 30 Jun 2010 09:31:05 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4FD961DB803E
	for <linux-mm@kvack.org>; Wed, 30 Jun 2010 09:31:05 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 080031DB803B
	for <linux-mm@kvack.org>; Wed, 30 Jun 2010 09:31:05 +0900 (JST)
Date: Wed, 30 Jun 2010 09:26:33 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [S+Q 08/16] slub: remove dynamic dma slab allocation
Message-Id: <20100630092633.a5184e16.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.1006291039260.16135@router.home>
References: <20100625212026.810557229@quilx.com>
	<20100625212105.765531312@quilx.com>
	<20100628113308.a9b6e834.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1006291039260.16135@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>, Matt Mackall <mpm@selenic.com>
List-ID: <linux-mm.kvack.org>

On Tue, 29 Jun 2010 10:41:59 -0500 (CDT)
Christoph Lameter <cl@linux-foundation.org> wrote:

> On Mon, 28 Jun 2010, KAMEZAWA Hiroyuki wrote:
> 
> > Uh...I think just using GFP_KERNEL drops too much
> > requests-from-user-via-gfp_mask.
> 
> Sorry I do not understand what the issue is? The dma slabs are allocated
> while user space is not active yet.
> 
Sorry, I misunderstood the patch. It seems ok, now.

> Please do not quote diff hunks that you do not comment on. I am on a slow
> link (vacation) and its awkward to check for comments...

Sure.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

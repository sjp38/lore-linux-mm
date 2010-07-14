Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id C1F086B02A3
	for <linux-mm@kvack.org>; Wed, 14 Jul 2010 19:52:31 -0400 (EDT)
Received: from hpaq1.eem.corp.google.com (hpaq1.eem.corp.google.com [172.25.149.1])
	by smtp-out.google.com with ESMTP id o6ENqTQs027899
	for <linux-mm@kvack.org>; Wed, 14 Jul 2010 16:52:29 -0700
Received: from pwi6 (pwi6.prod.google.com [10.241.219.6])
	by hpaq1.eem.corp.google.com with ESMTP id o6ENqRAD031640
	for <linux-mm@kvack.org>; Wed, 14 Jul 2010 16:52:27 -0700
Received: by pwi6 with SMTP id 6so94498pwi.10
        for <linux-mm@kvack.org>; Wed, 14 Jul 2010 16:52:26 -0700 (PDT)
Date: Wed, 14 Jul 2010 16:52:24 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [S+Q2 00/19] SLUB with queueing (V2) beats SLAB netperf TCP_RR
In-Reply-To: <20100709190706.938177313@quilx.com>
Message-ID: <alpine.DEB.2.00.1007141650110.29110@chino.kir.corp.google.com>
References: <20100709190706.938177313@quilx.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Fri, 9 Jul 2010, Christoph Lameter wrote:

> The following patchset cleans some pieces up and then equips SLUB with
> per cpu queues that work similar to SLABs queues.

Pekka, I think patches 4-8 could be applied to your tree now, they're 
relatively unchanged from what's been posted before.  (I didn't ack patch 
9 because I think it makes slab_lock() -> slab_unlock() matching more 
difficult with little win, but I don't feel strongly about it.)

I'd also consider patch 7 for 2.6.35-rc6 (and -stable).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 6B8B76B02A3
	for <linux-mm@kvack.org>; Wed, 14 Jul 2010 19:49:08 -0400 (EDT)
Received: from wpaz29.hot.corp.google.com (wpaz29.hot.corp.google.com [172.24.198.93])
	by smtp-out.google.com with ESMTP id o6ENn5FV002655
	for <linux-mm@kvack.org>; Wed, 14 Jul 2010 16:49:05 -0700
Received: from pvd12 (pvd12.prod.google.com [10.241.209.204])
	by wpaz29.hot.corp.google.com with ESMTP id o6ENn4eY024601
	for <linux-mm@kvack.org>; Wed, 14 Jul 2010 16:49:04 -0700
Received: by pvd12 with SMTP id 12so87210pvd.31
        for <linux-mm@kvack.org>; Wed, 14 Jul 2010 16:49:04 -0700 (PDT)
Date: Wed, 14 Jul 2010 16:48:59 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [S+Q2 07/19] slub: Allow removal of slab caches during boot
In-Reply-To: <20100709190853.770833931@quilx.com>
Message-ID: <alpine.DEB.2.00.1007141647340.29110@chino.kir.corp.google.com>
References: <20100709190706.938177313@quilx.com> <20100709190853.770833931@quilx.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Roland Dreier <rdreier@cisco.com>, linux-kernel@vger.kernel.org, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Fri, 9 Jul 2010, Christoph Lameter wrote:

> If a slab cache is removed before we have setup sysfs then simply skip over
> the sysfs handling.
> 
> Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> Cc: Roland Dreier <rdreier@cisco.com>
> Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

Acked-by: David Rientjes <rientjes@google.com>

I missed this case earlier because I didn't consider slab caches being 
created and destroyed prior to slab_state == SYSFS, sorry!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

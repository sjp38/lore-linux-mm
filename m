Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id E23EA6B02A3
	for <linux-mm@kvack.org>; Wed, 14 Jul 2010 18:17:01 -0400 (EDT)
Received: from kpbe18.cbf.corp.google.com (kpbe18.cbf.corp.google.com [172.25.105.82])
	by smtp-out.google.com with ESMTP id o6EMGwVv014484
	for <linux-mm@kvack.org>; Wed, 14 Jul 2010 15:16:58 -0700
Received: from pvh1 (pvh1.prod.google.com [10.241.210.193])
	by kpbe18.cbf.corp.google.com with ESMTP id o6EMGuIF026507
	for <linux-mm@kvack.org>; Wed, 14 Jul 2010 15:16:57 -0700
Received: by pvh1 with SMTP id 1so46945pvh.41
        for <linux-mm@kvack.org>; Wed, 14 Jul 2010 15:16:56 -0700 (PDT)
Date: Wed, 14 Jul 2010 15:16:53 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [S+Q2 06/19] slub: Check kasprintf results in
 kmem_cache_init()
In-Reply-To: <20100709190853.195193717@quilx.com>
Message-ID: <alpine.DEB.2.00.1007141515560.17291@chino.kir.corp.google.com>
References: <20100709190706.938177313@quilx.com> <20100709190853.195193717@quilx.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Fri, 9 Jul 2010, Christoph Lameter wrote:

> Small allocations may fail during slab bringup which is fatal. Add a BUG_ON()
> so that we fail immediately rather than failing later during sysfs
> processing.
> 
> CC: David Rientjes <rientjes@google.com>
> Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

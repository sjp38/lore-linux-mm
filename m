Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 03C846B01B2
	for <linux-mm@kvack.org>; Sun, 27 Jun 2010 15:25:36 -0400 (EDT)
Received: from wpaz21.hot.corp.google.com (wpaz21.hot.corp.google.com [172.24.198.85])
	by smtp-out.google.com with ESMTP id o5RJPYqb020599
	for <linux-mm@kvack.org>; Sun, 27 Jun 2010 12:25:34 -0700
Received: from pva18 (pva18.prod.google.com [10.241.209.18])
	by wpaz21.hot.corp.google.com with ESMTP id o5RJPWkO020987
	for <linux-mm@kvack.org>; Sun, 27 Jun 2010 12:25:33 -0700
Received: by pva18 with SMTP id 18so2499688pva.11
        for <linux-mm@kvack.org>; Sun, 27 Jun 2010 12:25:32 -0700 (PDT)
Date: Sun, 27 Jun 2010 12:25:29 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [S+Q 02/16] [PATCH 1/2 UPDATED] percpu: make @dyn_size always
 mean min dyn_size in first chunk init functions
In-Reply-To: <4C2782F9.6030803@suse.de>
Message-ID: <alpine.DEB.2.00.1006271225170.7487@chino.kir.corp.google.com>
References: <20100625212026.810557229@quilx.com> <20100625212102.196049458@quilx.com> <alpine.DEB.2.00.1006262155260.12531@chino.kir.corp.google.com> <4C270A09.3070305@kernel.org> <4C2782F9.6030803@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Tejun Heo <teheo@suse.de>
Cc: Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>, Matt Mackall <mpm@selenic.com>
List-ID: <linux-mm.kvack.org>

On Sun, 27 Jun 2010, Tejun Heo wrote:

> In pcpu_build_alloc_info() and pcpu_embed_first_chunk(), @dyn_size was
> ssize_t, -1 meant auto-size, 0 forced 0 and positive meant minimum
> size.  There's no use case for forcing 0 and the upcoming early alloc
> support always requires non-zero dynamic size.  Make @dyn_size always
> mean minimum dyn_size.
> 
> While at it, make pcpu_build_alloc_info() static which doesn't have
> any external caller as suggested by David Rientjes.
> 
> Signed-off-by: Tejun Heo <tj@kernel.org>
> Cc: David Rientjes <rientjes@google.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

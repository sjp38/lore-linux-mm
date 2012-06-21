Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 102426B007B
	for <linux-mm@kvack.org>; Thu, 21 Jun 2012 03:53:30 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so2248017pbb.14
        for <linux-mm@kvack.org>; Thu, 21 Jun 2012 00:53:30 -0700 (PDT)
Date: Thu, 21 Jun 2012 00:53:26 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/4] slab: rename gfpflags to allocflags
In-Reply-To: <1340225959-1966-2-git-send-email-glommer@parallels.com>
Message-ID: <alpine.DEB.2.00.1206210053160.31077@chino.kir.corp.google.com>
References: <1340225959-1966-1-git-send-email-glommer@parallels.com> <1340225959-1966-2-git-send-email-glommer@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, Cristoph Lameter <cl@linux.com>, Pekka Enberg <penberg@cs.helsinki.fi>

On Thu, 21 Jun 2012, Glauber Costa wrote:

> A consistent name with slub saves us an acessor function.
> In both caches, this field represents the same thing. We would
> like to use it from the mem_cgroup code.
> 
> Signed-off-by: Glauber Costa <glommer@parallels.com>
> Acked-by: Christoph Lameter <cl@linux.com>
> CC: Pekka Enberg <penberg@cs.helsinki.fi>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

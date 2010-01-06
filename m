Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 23CF36B0062
	for <linux-mm@kvack.org>; Wed,  6 Jan 2010 03:20:45 -0500 (EST)
Received: by fg-out-1718.google.com with SMTP id 19so2036851fgg.8
        for <linux-mm@kvack.org>; Wed, 06 Jan 2010 00:20:42 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <4B443AE3.2080800@linux.intel.com>
References: <4B443AE3.2080800@linux.intel.com>
Date: Wed, 6 Jan 2010 10:20:42 +0200
Message-ID: <84144f021001060020v57535d5bwc65b482eca669bc5@mail.gmail.com>
Subject: Re: [PATCH v3] slab: initialize unused alien cache entry as NULL at
	alloc_alien_cache().
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Haicheng Li <haicheng.li@linux.intel.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, linux-mm@kvack.org, Matt Mackall <mpm@selenic.com>, Andi Kleen <andi@firstfloor.org>, Eric Dumazet <eric.dumazet@gmail.com>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Jan 6, 2010 at 9:25 AM, Haicheng Li <haicheng.li@linux.intel.com> wrote:
> Comparing with existing code, it's a simpler way to use kzalloc_node()
> to ensure that each unused alien cache entry is NULL.
>
> CC: Pekka Enberg <penberg@cs.helsinki.fi>
> CC: Eric Dumazet <eric.dumazet@gmail.com>
> Acked-by: Andi Kleen <ak@linux.intel.com>
> Acked-by: Christoph Lameter <cl@linux-foundation.org>
> Reviewed-by: Matt Mackall <mpm@selenic.com>
> Signed-off-by: Haicheng Li <haicheng.li@linux.intel.com>

I can find a trace of Andi acking the previous version of this patch
but I don't see an ACK from Christoph nor a revieved-by from Matt. Was
I not CC'd on those emails or what's going on here?

                        Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

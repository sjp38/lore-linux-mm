Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 8E539620002
	for <linux-mm@kvack.org>; Tue, 22 Dec 2009 17:38:19 -0500 (EST)
Subject: Re: [PATCH] slab: initialize unused alien cache entry as NULL at
 alloc_alien_cache().
From: Matt Mackall <mpm@selenic.com>
In-Reply-To: <4B30BDA8.1070904@linux.intel.com>
References: <4B30BDA8.1070904@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 22 Dec 2009 16:38:05 -0600
Message-ID: <1261521485.3000.1692.camel@calx>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Haicheng Li <haicheng.li@linux.intel.com>
Cc: linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, andi@firstfloor.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 2009-12-22 at 20:38 +0800, Haicheng Li wrote:

>   	ac_ptr = kmalloc_node(memsize, gfp, node);
>   	if (ac_ptr) {
> +		memset(ac_ptr, 0, memsize);

Please use kzalloc_node here.

I'm not sure what's going on with nr_node_id vs MAX_NUMNODES, so I think
we need to see an answer to Christoph's question before going forward
with this.

-- 
http://selenic.com : development and support for Mercurial and Linux


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

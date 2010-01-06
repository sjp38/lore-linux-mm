Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 7792F6B0062
	for <linux-mm@kvack.org>; Wed,  6 Jan 2010 03:39:24 -0500 (EST)
Message-ID: <4B444C39.3020901@linux.intel.com>
Date: Wed, 06 Jan 2010 16:39:21 +0800
From: Haicheng Li <haicheng.li@linux.intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3] slab: initialize unused alien cache entry as NULL
 at 	alloc_alien_cache().
References: <4B443AE3.2080800@linux.intel.com> <84144f021001060020v57535d5bwc65b482eca669bc5@mail.gmail.com>
In-Reply-To: <84144f021001060020v57535d5bwc65b482eca669bc5@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Christoph Lameter <cl@linux-foundation.org>, linux-mm@kvack.org, Matt Mackall <mpm@selenic.com>, Andi Kleen <andi@firstfloor.org>, Eric Dumazet <eric.dumazet@gmail.com>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Pekka Enberg wrote:
 > I can find a trace of Andi acking the previous version of this patch
 > but I don't see an ACK from Christoph nor a revieved-by from Matt. Was
 > I not CC'd on those emails or what's going on here?
 >

Pekka,

Christoph said he will ack this patch if remove the change of MAX_NUMNODES (see below),
so I add him directly as Acked-by in this revised patch. And also, I got review
comments from Matt for v1 and changed the patch accordingly.

Is it a violation of the rule? if so, I'm sorry, actually not quite clear with the rule.



Christoph Lameter wrote:
 > On Wed, 23 Dec 2009, Haicheng Li wrote:
 >
 >> @@ -966,18 +966,16 @@ static void *alternate_node_alloc(struct kmem_cache *,
 >> gfp_t);
 >>  static struct array_cache **alloc_alien_cache(int node, int limit, gfp_t gfp)
 >>  {
 >>  	struct array_cache **ac_ptr;
 >> -	int memsize = sizeof(void *) * nr_node_ids;
 >> +	int memsize = sizeof(void *) * MAX_NUMNODES;
 >>  	int i;
 >
 > Remove this change and I will ack the patch.
 >


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

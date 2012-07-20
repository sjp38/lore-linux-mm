Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 8B9D06B0044
	for <linux-mm@kvack.org>; Fri, 20 Jul 2012 18:33:16 -0400 (EDT)
Message-ID: <5009DC04.4020809@parallels.com>
Date: Fri, 20 Jul 2012 19:30:28 -0300
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: Common [0/4] Sl[auo]b: Common code rework V6 (limited)
References: <20120706202509.294809131@linux.com>
In-Reply-To: <20120706202509.294809131@linux.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>, Joonsoo Kim <js1304@gmail.com>

On 07/06/2012 05:25 PM, Christoph Lameter wrote:
> 
> V5->V6:
> - Patches against Pekka's for-next tree.
> - Go slow and cut down to just patches that are safe
>   (there will likely be some churn already due to the
>   mutex unification between slabs)
> - More to come next week when I have more time (
>   took me almost the whole week to catch up after
>   being gone for awhile).
> 
> V4->V5
> - Rediff against current upstream + Pekka's cleanup branch.
> 
> V3->V4:
> - Do not use the COMMON macro anymore.
> - Fixup various issues
> - No general sysfs support yet due to lockdep issues with
>   keys in kmalloc'ed memory.
> 
> V2->V3:
> - Incorporate more feedback from Joonsoo Kim and Glauber Costa
> - And a couple more patches to deal with slab duping and move
>   more code to slab_common.c
> 
> V1->V2:
> - Incorporate glommers feedback.
> - Add 2 more patches dealing with common code in kmem_cache_destroy
> 

This series has the warning problem on oops label that I've already told
you about. But it seems this is already known by now =)

Sorry, just back from vacations.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

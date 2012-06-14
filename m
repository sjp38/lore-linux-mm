Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id A26206B0070
	for <linux-mm@kvack.org>; Thu, 14 Jun 2012 04:16:52 -0400 (EDT)
Message-ID: <4FD99D58.1060708@parallels.com>
Date: Thu, 14 Jun 2012 12:14:16 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: Common [00/20] Sl[auo]b: Common code rework V5 (for merge)
References: <20120613152451.465596612@linux.com>
In-Reply-To: <20120613152451.465596612@linux.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>, Joonsoo Kim <js1304@gmail.com>

On 06/13/2012 07:24 PM, Christoph Lameter wrote:
> V4->V5
> - Rediff against current upstream + Pekka's cleanup branch.
>
> V3->V4:
> - Do not use the COMMON macro anymore.
> - Fixup various issues
> - No general sysfs support yet due to lockdep issues with
>    keys in kmalloc'ed memory.
>
> V2->V3:
> - Incorporate more feedback from Joonsoo Kim and Glauber Costa
> - And a couple more patches to deal with slab duping and move
>    more code to slab_common.c
>
> V1->V2:
> - Incorporate glommers feedback.
> - Add 2 more patches dealing with common code in kmem_cache_destroy
>
> This is a series of patches that extracts common functionality from
> slab allocators into a common code base. The intend is to standardize
> as much as possible of the allocator behavior while keeping the
> distinctive features of each allocator which are mostly due to their
> storage format and serialization approaches.
>
> This patchset makes a beginning by extracting common functionality in
> kmem_cache_create() and kmem_cache_destroy(). However, there are
> numerous other areas where such work could be beneficial:
>

Christoph,

I rebased my series on top of yours, and started testing. After some 
debugging, some of the bugs were pinpointed to your code. I was going to 
send patches for it in the belief the series was already in somewhere.

Since you are sending it again, I'll just point them here. If people 
prefer, to avoid having you resend the series, I'll be happy to post mine.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

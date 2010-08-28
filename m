Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 187F76B01F3
	for <linux-mm@kvack.org>; Sat, 28 Aug 2010 11:57:06 -0400 (EDT)
Message-ID: <4C7931CE.4050506@redhat.com>
Date: Sat, 28 Aug 2010 11:57:02 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm:  remove alignment padding from anon_vma on (some)
 64 bit builds
References: <1283004586.1912.10.camel@castor.rsk>
In-Reply-To: <1283004586.1912.10.camel@castor.rsk>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Richard Kennedy <richard@rsk.demon.co.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On 08/28/2010 10:09 AM, Richard Kennedy wrote:
> Reorder structure anon_vma to remove alignment padding on 64 builds when
> (CONFIG_KSM || CONFIG_MIGRATION).
> This will shrink the size of the anon_vma structure from 40 to 32 bytes
> &  allow more objects per slab in its kmem_cache.
>
> Under slub the objects in the anon_vma kmem_cache will then be 40 bytes
> with 102 objects per slab.
> (On v2.6.36 without this patch,the size is 48 bytes and 85
> objects/slab.)
>
> compiled&  tested on x86_64 using SLUB
>
> Signed-off-by: Richard Kennedy<richard@rsk.demon.co.uk>

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

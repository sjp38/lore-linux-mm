Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 4A8276B0085
	for <linux-mm@kvack.org>; Thu,  7 Oct 2010 01:35:00 -0400 (EDT)
Message-ID: <4CAD5C00.2020403@cs.helsinki.fi>
Date: Thu, 07 Oct 2010 08:34:56 +0300
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] SLAB: Add function to get slab cache for a page
References: <1286398930-11956-1-git-send-email-andi@firstfloor.org> <1286398930-11956-2-git-send-email-andi@firstfloor.org> <alpine.DEB.2.00.1010061640240.8083@router.home>
In-Reply-To: <alpine.DEB.2.00.1010061640240.8083@router.home>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org, mpm@selenic.com, Andi Kleen <ak@linux.intel.com>
List-ID: <linux-mm.kvack.org>

On 10/7/10 12:42 AM, Christoph Lameter wrote:
> On Wed, 6 Oct 2010, Andi Kleen wrote:
>
>> +struct kmem_cache *kmem_page_cache(struct page *p);
>
> That sounds as if we do something with the page cache.
>
> kmem_cache_of_slab_page(struct page *)

kmem_page_to_cache(), for example.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

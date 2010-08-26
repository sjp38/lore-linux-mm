Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id DA20F6B01F2
	for <linux-mm@kvack.org>; Thu, 26 Aug 2010 14:17:34 -0400 (EDT)
Message-ID: <4C76AFAE.7010907@cs.helsinki.fi>
Date: Thu, 26 Aug 2010 21:17:18 +0300
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: linux-next: Tree for August 25 (mm/slub)
References: <20100825132057.c8416bef.sfr@canb.auug.org.au> <20100825094559.bc652afe.randy.dunlap@oracle.com> <alpine.DEB.2.00.1008251405590.22117@router.home> <4C757D5E.1040307@oracle.com>
In-Reply-To: <4C757D5E.1040307@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Randy Dunlap <randy.dunlap@oracle.com>
Cc: Christoph Lameter <cl@linux.com>, Stephen Rothwell <sfr@canb.auug.org.au>, linux-mm@kvack.org, linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On 25.8.2010 23.30, Randy Dunlap wrote:
> On 08/25/10 12:07, Christoph Lameter wrote:
>> On Wed, 25 Aug 2010, Randy Dunlap wrote:
>>
>>> mm/slub.c:1732: error: implicit declaration of function 'slab_pre_alloc_hook'
>>> mm/slub.c:1751: error: implicit declaration of function 'slab_post_alloc_hook'
>>> mm/slub.c:1881: error: implicit declaration of function 'slab_free_hook'
>>> mm/slub.c:1886: error: implicit declaration of function 'slab_free_hook_irq'
>>
>> Empty functions are missing if the runtime debuggability option is
>> compiled
>> out.
>>
>>
>> Subject: slub: Add dummy functions for the !SLUB_DEBUG case
>>
>> Provide the fall back functions to empty hooks if SLUB_DEBUG is not set.
>>
>> Signed-off-by: Christoph Lameter<cl@linux.com>
>
> Acked-by: Randy Dunlap<randy.dunlap@oracle.com>

Applied, thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 4F24E6B01F2
	for <linux-mm@kvack.org>; Thu, 26 Aug 2010 14:17:25 -0400 (EDT)
Message-ID: <4C76AFA2.8010801@cs.helsinki.fi>
Date: Thu, 26 Aug 2010 21:17:06 +0300
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: linux-next: Tree for August 25 (mm/slub)
References: <20100825132057.c8416bef.sfr@canb.auug.org.au>	<20100825094559.bc652afe.randy.dunlap@oracle.com>	<alpine.DEB.2.00.1008251409260.22117@router.home>	<20100825122134.2ac33360.randy.dunlap@oracle.com>	<alpine.DEB.2.00.1008251447410.22117@router.home> <20100825131344.a2c26b31.randy.dunlap@oracle.com>
In-Reply-To: <20100825131344.a2c26b31.randy.dunlap@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Randy Dunlap <randy.dunlap@oracle.com>
Cc: Christoph Lameter <cl@linux.com>, Stephen Rothwell <sfr@canb.auug.org.au>, linux-mm@kvack.org, linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On 25.8.2010 23.13, Randy Dunlap wrote:
> On Wed, 25 Aug 2010 14:51:14 -0500 (CDT) Christoph Lameter wrote:
>
>> On Wed, 25 Aug 2010, Randy Dunlap wrote:
>>
>>> Certainly.  config file is attached.
>>
>> Ah. Memory hotplug....
>>
>>
>>
>> Subject: Slub: Fix up missing kmalloc_cache ->  kmem_cache_node case for memoryhotplug
>>
>> Memory hotplug allocates and frees per node structures. Use the correct name.
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

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f170.google.com (mail-ie0-f170.google.com [209.85.223.170])
	by kanga.kvack.org (Postfix) with ESMTP id 2718D6B0031
	for <linux-mm@kvack.org>; Tue,  1 Jul 2014 17:52:11 -0400 (EDT)
Received: by mail-ie0-f170.google.com with SMTP id tr6so8784905ieb.15
        for <linux-mm@kvack.org>; Tue, 01 Jul 2014 14:52:11 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id bm3si36278709icb.49.2014.07.01.14.52.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 01 Jul 2014 14:52:10 -0700 (PDT)
Message-ID: <53B32D80.8000601@oracle.com>
Date: Tue, 01 Jul 2014 17:52:00 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: mm: slub: invalid memory access in setup_object
References: <53AAFDF7.2010607@oracle.com>	<alpine.DEB.2.11.1406251228130.29216@gentwo.org>	<alpine.DEB.2.02.1406301500410.13545@chino.kir.corp.google.com>	<alpine.DEB.2.11.1407010956470.5353@gentwo.org> <20140701144947.5ce3f93729759d8f38d7813a@linux-foundation.org>
In-Reply-To: <20140701144947.5ce3f93729759d8f38d7813a@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@gentwo.org>
Cc: David Rientjes <rientjes@google.com>, Wei Yang <weiyang@linux.vnet.ibm.com>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Dave Jones <davej@redhat.com>

On 07/01/2014 05:49 PM, Andrew Morton wrote:
> On Tue, 1 Jul 2014 09:58:52 -0500 (CDT) Christoph Lameter <cl@gentwo.org> wrote:
> 
>> On Mon, 30 Jun 2014, David Rientjes wrote:
>>
>>> It's not at all clear to me that that patch is correct.  Wei?
>>
>> Looks ok to me. But I do not like the convoluted code in new_slab() which
>> Wei's patch does not make easier to read. Makes it difficult for the
>> reader to see whats going on.
>>
>> Lets drop the use of the variable named "last".
>>
>>
>> Subject: slub: Only call setup_object once for each object
>>
>> Modify the logic for object initialization to be less convoluted
>> and initialize an object only once.
>>
> 
> Well, um.  Wei's changelog was much better:
> 
> : When a kmem_cache is created with ctor, each object in the kmem_cache will
> : be initialized before use.  In the slub implementation, the first object
> : will be initialized twice.
> : 
> : This patch avoids the duplication of initialization of the first object.
> : 
> : Fixes commit 7656c72b5a63: ("SLUB: add macros for scanning objects in a
> : slab").
> 
> I can copy that text over and add the reported-by etc (ho hum) but I
> have a tiny feeling that this patch hasn't been rigorously tested? 
> Perhaps someone (Wei?) can do that?
> 
> And we still don't know why Sasha's kernel went oops.

I only saw this oops once, and after David's message yesterday I tried reverting
the patch he pointed out, but not much changed.

Is there a better way to stress test slub?


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 001126B0038
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 16:26:15 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id gt1so35527761wjc.0
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 13:26:15 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v85si350805wmv.132.2017.01.25.13.26.14
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 25 Jan 2017 13:26:14 -0800 (PST)
Subject: Re: [PATCH RFC] mm: Rename SLAB_DESTROY_BY_RCU to
 SLAB_TYPESAFE_BY_RCU
References: <20170118110731.GA15949@linux.vnet.ibm.com>
 <20170125202533.GA22138@cmpxchg.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <a4cb93f8-0ca4-57aa-f395-1b22143a32bd@suse.cz>
Date: Wed, 25 Jan 2017 22:26:08 +0100
MIME-Version: 1.0
In-Reply-To: <20170125202533.GA22138@cmpxchg.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org

On 01/25/2017 09:25 PM, Johannes Weiner wrote:
> On Wed, Jan 18, 2017 at 03:07:32AM -0800, Paul E. McKenney wrote:
>> A group of Linux kernel hackers reported chasing a bug that resulted
>> from their assumption that SLAB_DESTROY_BY_RCU provided an existence
>> guarantee, that is, that no block from such a slab would be reallocated
>> during an RCU read-side critical section.  Of course, that is not the
>> case.  Instead, SLAB_DESTROY_BY_RCU only prevents freeing of an entire
>> slab of blocks.
>>
>> However, there is a phrase for this, namely "type safety".  This commit
>> therefore renames SLAB_DESTROY_BY_RCU to SLAB_TYPESAFE_BY_RCU in order
>> to avoid future instances of this sort of confusion.
>>
>> Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
>
> This has come up in the past, and it always proved hard to agree on a
> better name for it. But I like SLAB_TYPESAFE_BY_RCU the best out of
> all proposals, and it's much more poignant than the current name.

Heh, until I've seen this thread I had the same wrong assumption about the flag, 
so it suprised me. Good thing I didn't have a chance to use it wrongly so far :)

"Type safety" in this context seems quite counter-intuitive for me, as I've only 
heard it to describe programming languages. But that's fine when the name sounds 
so exotic that one has to look up what it does. Much safer than when the meaning 
seems obvious, but in fact it's misleading.

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> Acked-by: Johannes Weiner <hannes@cmpxchg.org>
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

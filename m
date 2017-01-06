Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 819336B0038
	for <linux-mm@kvack.org>; Fri,  6 Jan 2017 12:08:45 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id q20so13894329ioi.0
        for <linux-mm@kvack.org>; Fri, 06 Jan 2017 09:08:45 -0800 (PST)
Received: from mail-io0-x22a.google.com (mail-io0-x22a.google.com. [2607:f8b0:4001:c06::22a])
        by mx.google.com with ESMTPS id 68si2657659itx.100.2017.01.06.09.08.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Jan 2017 09:08:44 -0800 (PST)
Received: by mail-io0-x22a.google.com with SMTP id p127so60991188iop.3
        for <linux-mm@kvack.org>; Fri, 06 Jan 2017 09:08:44 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <97be60da-72df-ad8f-db03-03f01c392823@suse.cz>
References: <20170106152052.GS5556@dhcp22.suse.cz> <CANn89i+QZs0cSPK21qMe6LXw+AeAMZ_tKEDUEnCsJ_cd+q0t-g@mail.gmail.com>
 <20901069-5eb7-f5ff-0641-078635544531@suse.cz> <CANn89iLy2KMUu80KekhvO31G4uXr4B0K8zvGjhfyBBp9d_ncBg@mail.gmail.com>
 <97be60da-72df-ad8f-db03-03f01c392823@suse.cz>
From: Eric Dumazet <edumazet@google.com>
Date: Fri, 6 Jan 2017 09:08:43 -0800
Message-ID: <CANn89i+pRwa3KES1ane4ZfBpw4Y7Ne5OLZmkt=K8n5E6qF9xvA@mail.gmail.com>
Subject: Re: __GFP_REPEAT usage in fq_alloc_node
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Fri, Jan 6, 2017 at 8:55 AM, Vlastimil Babka <vbabka@suse.cz> wrote:
> On 01/06/2017 05:48 PM, Eric Dumazet wrote:
>> On Fri, Jan 6, 2017 at 8:31 AM, Vlastimil Babka <vbabka@suse.cz> wrote:
>>
>>>
>>> I wonder what's that cause of the penalty (when accessing the vmapped
>>> area I suppose?) Is it higher risk of collisions cache misses within the
>>> area, compared to consecutive physical adresses?
>>
>> I believe tests were done with 48 fq qdisc, each having 2^16 slots.
>> So I had 48 blocs,of 524288 bytes.
>>
>> Trying a bit harder at setup time to get 128 consecutive pages got
>> less TLB pressure.
>
> Hmm that's rather surprising to me. TLB caches the page table lookups
> and the PFN's of the physical pages it translates to shouldn't matter -
> the page tables will look the same. With 128 consecutive pages could
> manifest the reduced collision cache miss effect though.
>

To be clear, the difference came from :

Using kmalloc() to allocate 48 x 524288 bytes

Or using vmalloc()

Are you telling me HugePages are not in play there ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

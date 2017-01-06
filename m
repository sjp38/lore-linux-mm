Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 399F26B0069
	for <linux-mm@kvack.org>; Fri,  6 Jan 2017 11:55:25 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id sr6so6603891wjb.2
        for <linux-mm@kvack.org>; Fri, 06 Jan 2017 08:55:25 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d10si3112838wmi.71.2017.01.06.08.55.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 06 Jan 2017 08:55:24 -0800 (PST)
Subject: Re: __GFP_REPEAT usage in fq_alloc_node
References: <20170106152052.GS5556@dhcp22.suse.cz>
 <CANn89i+QZs0cSPK21qMe6LXw+AeAMZ_tKEDUEnCsJ_cd+q0t-g@mail.gmail.com>
 <20901069-5eb7-f5ff-0641-078635544531@suse.cz>
 <CANn89iLy2KMUu80KekhvO31G4uXr4B0K8zvGjhfyBBp9d_ncBg@mail.gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <97be60da-72df-ad8f-db03-03f01c392823@suse.cz>
Date: Fri, 6 Jan 2017 17:55:23 +0100
MIME-Version: 1.0
In-Reply-To: <CANn89iLy2KMUu80KekhvO31G4uXr4B0K8zvGjhfyBBp9d_ncBg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <edumazet@google.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On 01/06/2017 05:48 PM, Eric Dumazet wrote:
> On Fri, Jan 6, 2017 at 8:31 AM, Vlastimil Babka <vbabka@suse.cz> wrote:
> 
>>
>> I wonder what's that cause of the penalty (when accessing the vmapped
>> area I suppose?) Is it higher risk of collisions cache misses within the
>> area, compared to consecutive physical adresses?
> 
> I believe tests were done with 48 fq qdisc, each having 2^16 slots.
> So I had 48 blocs,of 524288 bytes.
> 
> Trying a bit harder at setup time to get 128 consecutive pages got
> less TLB pressure.

Hmm that's rather surprising to me. TLB caches the page table lookups
and the PFN's of the physical pages it translates to shouldn't matter -
the page tables will look the same. With 128 consecutive pages could
manifest the reduced collision cache miss effect though.

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

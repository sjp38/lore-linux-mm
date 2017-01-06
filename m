Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 849E86B026B
	for <linux-mm@kvack.org>; Fri,  6 Jan 2017 11:31:42 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id t20so5988823wju.5
        for <linux-mm@kvack.org>; Fri, 06 Jan 2017 08:31:42 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fz16si89691915wjc.184.2017.01.06.08.31.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 06 Jan 2017 08:31:41 -0800 (PST)
Subject: Re: __GFP_REPEAT usage in fq_alloc_node
References: <20170106152052.GS5556@dhcp22.suse.cz>
 <CANn89i+QZs0cSPK21qMe6LXw+AeAMZ_tKEDUEnCsJ_cd+q0t-g@mail.gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <20901069-5eb7-f5ff-0641-078635544531@suse.cz>
Date: Fri, 6 Jan 2017 17:31:40 +0100
MIME-Version: 1.0
In-Reply-To: <CANn89i+QZs0cSPK21qMe6LXw+AeAMZ_tKEDUEnCsJ_cd+q0t-g@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <edumazet@google.com>, Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On 01/06/2017 04:39 PM, Eric Dumazet wrote:
> On Fri, Jan 6, 2017 at 7:20 AM, Michal Hocko <mhocko@kernel.org> wrote:
>>
>> Hi Eric,
>> I am currently checking kmalloc with vmalloc fallback users and convert
>> them to a new kvmalloc helper [1]. While I am adding a support for
>> __GFP_REPEAT to kvmalloc [2] I was wondering what is the reason to use
>> __GFP_REPEAT in fq_alloc_node in the first place. c3bd85495aef
>> ("pkt_sched: fq: more robust memory allocation") doesn't mention
>> anything. Could you clarify this please?
>>
>> Thanks!
> 
> I guess this question applies to all __GFP_REPEAT usages in net/ ?
> 
> At the time, tests on the hardware I had in my labs showed that
> vmalloc() could deliver pages spread
> all over the memory and that was a small penalty (once memory is
> fragmented enough, not at boot time)

I wonder what's that cause of the penalty (when accessing the vmapped
area I suppose?) Is it higher risk of collisions cache misses within the
area, compared to consecutive physical adresses?

> I guess this wont be anymore a concern if I can finish my pending work
> about vmalloc() trying to get adjacent pages
> https://lkml.org/lkml/2016/12/21/285
> 
> Thanks.
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

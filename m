Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id A23EF6B0038
	for <linux-mm@kvack.org>; Fri,  6 Jan 2017 10:39:15 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id 71so576070259ioe.2
        for <linux-mm@kvack.org>; Fri, 06 Jan 2017 07:39:15 -0800 (PST)
Received: from mail-it0-x232.google.com (mail-it0-x232.google.com. [2607:f8b0:4001:c0b::232])
        by mx.google.com with ESMTPS id 139si35385504iou.36.2017.01.06.07.39.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Jan 2017 07:39:15 -0800 (PST)
Received: by mail-it0-x232.google.com with SMTP id x2so18139562itf.1
        for <linux-mm@kvack.org>; Fri, 06 Jan 2017 07:39:15 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170106152052.GS5556@dhcp22.suse.cz>
References: <20170106152052.GS5556@dhcp22.suse.cz>
From: Eric Dumazet <edumazet@google.com>
Date: Fri, 6 Jan 2017 07:39:14 -0800
Message-ID: <CANn89i+QZs0cSPK21qMe6LXw+AeAMZ_tKEDUEnCsJ_cd+q0t-g@mail.gmail.com>
Subject: Re: __GFP_REPEAT usage in fq_alloc_node
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Fri, Jan 6, 2017 at 7:20 AM, Michal Hocko <mhocko@kernel.org> wrote:
>
> Hi Eric,
> I am currently checking kmalloc with vmalloc fallback users and convert
> them to a new kvmalloc helper [1]. While I am adding a support for
> __GFP_REPEAT to kvmalloc [2] I was wondering what is the reason to use
> __GFP_REPEAT in fq_alloc_node in the first place. c3bd85495aef
> ("pkt_sched: fq: more robust memory allocation") doesn't mention
> anything. Could you clarify this please?
>
> Thanks!

I guess this question applies to all __GFP_REPEAT usages in net/ ?

At the time, tests on the hardware I had in my labs showed that
vmalloc() could deliver pages spread
all over the memory and that was a small penalty (once memory is
fragmented enough, not at boot time)

I guess this wont be anymore a concern if I can finish my pending work
about vmalloc() trying to get adjacent pages
https://lkml.org/lkml/2016/12/21/285

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

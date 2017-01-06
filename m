Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7CA766B0069
	for <linux-mm@kvack.org>; Fri,  6 Jan 2017 11:50:33 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id p189so23410082itg.2
        for <linux-mm@kvack.org>; Fri, 06 Jan 2017 08:50:33 -0800 (PST)
Received: from mail-io0-x22c.google.com (mail-io0-x22c.google.com. [2607:f8b0:4001:c06::22c])
        by mx.google.com with ESMTPS id p20si2639646itc.10.2017.01.06.08.50.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Jan 2017 08:50:32 -0800 (PST)
Received: by mail-io0-x22c.google.com with SMTP id v96so36471726ioi.0
        for <linux-mm@kvack.org>; Fri, 06 Jan 2017 08:50:32 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CANn89iLy2KMUu80KekhvO31G4uXr4B0K8zvGjhfyBBp9d_ncBg@mail.gmail.com>
References: <20170106152052.GS5556@dhcp22.suse.cz> <CANn89i+QZs0cSPK21qMe6LXw+AeAMZ_tKEDUEnCsJ_cd+q0t-g@mail.gmail.com>
 <20901069-5eb7-f5ff-0641-078635544531@suse.cz> <CANn89iLy2KMUu80KekhvO31G4uXr4B0K8zvGjhfyBBp9d_ncBg@mail.gmail.com>
From: Eric Dumazet <edumazet@google.com>
Date: Fri, 6 Jan 2017 08:50:31 -0800
Message-ID: <CANn89i++m2bmop_983MetxWkjsn6eMe06OeST_eGB+FtubB8DQ@mail.gmail.com>
Subject: Re: __GFP_REPEAT usage in fq_alloc_node
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Fri, Jan 6, 2017 at 8:48 AM, Eric Dumazet <edumazet@google.com> wrote:
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

Forgot to mention tests include DDOS, so hitting a random hash bucket
for every packet.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

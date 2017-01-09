Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id B94966B0266
	for <linux-mm@kvack.org>; Mon,  9 Jan 2017 09:31:51 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id x2so91244682itf.6
        for <linux-mm@kvack.org>; Mon, 09 Jan 2017 06:31:51 -0800 (PST)
Received: from mail-io0-x230.google.com (mail-io0-x230.google.com. [2607:f8b0:4001:c06::230])
        by mx.google.com with ESMTPS id f134si2339357itf.32.2017.01.09.06.31.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Jan 2017 06:31:51 -0800 (PST)
Received: by mail-io0-x230.google.com with SMTP id v96so81136819ioi.0
        for <linux-mm@kvack.org>; Mon, 09 Jan 2017 06:31:51 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170109095828.GE7495@dhcp22.suse.cz>
References: <20170106095115.GG5556@dhcp22.suse.cz> <20170106100433.GH5556@dhcp22.suse.cz>
 <20170106121642.GJ5556@dhcp22.suse.cz> <1483740889.9712.44.camel@edumazet-glaptop3.roam.corp.google.com>
 <20170107092746.GC5047@dhcp22.suse.cz> <CANn89iL7JTkV_r9Wqqcrsz1GJmTfWtxD1TUV1YOKsv3rwN-+vQ@mail.gmail.com>
 <20170109095828.GE7495@dhcp22.suse.cz>
From: Eric Dumazet <edumazet@google.com>
Date: Mon, 9 Jan 2017 06:31:50 -0800
Message-ID: <CANn89iLoC6uL8rfr_GWfuPeKasgw=JiuciSDN6EQBC0yFsgbww@mail.gmail.com>
Subject: Re: weird allocation pattern in alloc_ila_locks
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Tom Herbert <tom@herbertland.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Mon, Jan 9, 2017 at 1:58 AM, Michal Hocko <mhocko@kernel.org> wrote:

>
> Also this seems to be an init code so I assume a modprobe would have to
> set a non-default policy to make use of it. Does anybody do that out
> there?

This is not init code. Whole point of rhashtable is that the resizes
can happen anytime.
At boot time, most rhashtable would be tiny.
Then, when load permits, hashtables grow in size.

Yes, some applications make some specific choices about NUMA policies.

It would be perfectly possible to amend rhashtable to make sure that
allocations can respect this strategy.
(ie the NUMA policy could be an attribute of the rhashtable, instead
of being implicitly given by current process)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

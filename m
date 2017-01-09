Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 56CDD6B0038
	for <linux-mm@kvack.org>; Mon,  9 Jan 2017 12:53:44 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id 101so81750642iom.7
        for <linux-mm@kvack.org>; Mon, 09 Jan 2017 09:53:44 -0800 (PST)
Received: from mail-it0-x235.google.com (mail-it0-x235.google.com. [2607:f8b0:4001:c0b::235])
        by mx.google.com with ESMTPS id 68si10065560itz.83.2017.01.09.09.53.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Jan 2017 09:53:43 -0800 (PST)
Received: by mail-it0-x235.google.com with SMTP id x2so68951930itf.1
        for <linux-mm@kvack.org>; Mon, 09 Jan 2017 09:53:43 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170109174511.GA8306@dhcp22.suse.cz>
References: <20170106152052.GS5556@dhcp22.suse.cz> <CANn89i+QZs0cSPK21qMe6LXw+AeAMZ_tKEDUEnCsJ_cd+q0t-g@mail.gmail.com>
 <20170106160743.GU5556@dhcp22.suse.cz> <20170106161944.GW5556@dhcp22.suse.cz>
 <20170109102219.GF7495@dhcp22.suse.cz> <CANn89iKcHqyr=af2R7WyZRPawXt_bZkFAsbk0W_tkVt9VOGYFQ@mail.gmail.com>
 <20170109174511.GA8306@dhcp22.suse.cz>
From: Eric Dumazet <edumazet@google.com>
Date: Mon, 9 Jan 2017 09:53:42 -0800
Message-ID: <CANn89iJh2pSv19HkMGoisuGcs5oEdFp5rYz9oKKSh8TzBY2TxA@mail.gmail.com>
Subject: Re: __GFP_REPEAT usage in fq_alloc_node
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Mon, Jan 9, 2017 at 9:45 AM, Michal Hocko <mhocko@kernel.org> wrote:

> What about those non-default configurations. Do they really want to
> invoke the OOM killer rather than fallback to the vmalloc?

In our case, we use 4096 slots per fq, so that is a 16KB memory allocation.
And these allocations happen right after boot, while we have plenty of
non fragmented memory.

Presumably falling back to vmalloc() would be just fine.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

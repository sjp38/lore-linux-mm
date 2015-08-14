Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f182.google.com (mail-lb0-f182.google.com [209.85.217.182])
	by kanga.kvack.org (Postfix) with ESMTP id 758146B0038
	for <linux-mm@kvack.org>; Fri, 14 Aug 2015 09:26:51 -0400 (EDT)
Received: by lbbpu9 with SMTP id pu9so45477445lbb.3
        for <linux-mm@kvack.org>; Fri, 14 Aug 2015 06:26:50 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f8si10061414wjr.70.2015.08.14.06.26.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 14 Aug 2015 06:26:49 -0700 (PDT)
Subject: Re: [PATCH] mm: make page pfmemalloc check more robust
References: <1439456364-4530-1-git-send-email-mhocko@kernel.org>
 <55CC5FA0.300@suse.cz>
 <1439476856.7960.8.camel@edumazet-glaptop2.roam.corp.google.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <55CDEC95.5050307@suse.cz>
Date: Fri, 14 Aug 2015 15:26:45 +0200
MIME-Version: 1.0
In-Reply-To: <1439476856.7960.8.camel@edumazet-glaptop2.roam.corp.google.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: mhocko@kernel.org, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Jiri Bohac <jbohac@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, "David S. Miller" <davem@davemloft.net>, LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org, Michal Hocko <mhocko@suse.com>

On 08/13/2015 04:40 PM, Eric Dumazet wrote:
> On Thu, 2015-08-13 at 11:13 +0200, Vlastimil Babka wrote:
>
>> Given that this apparently isn't the first case of this localhost issue,
>> I wonder if network code should just clear skb->pfmemalloc during send
>> (or maybe just send over localhost). That would be probably easier than
>> distinguish the __skb_fill_page_desc() callers for send vs receive.
>
> Would this still needed after this patch ?

Not until another corner case is discovered :) Or something passes a 
genuine pfmemalloc page to a socket (sending contents of some slab 
objects perhaps, where the slab page was allocated as pfmemalloc? Dunno 
if that can happen right now).

> It is sad we do not have a SNMP counter to at least count how often we
> drop skb because pfmemalloc is set.
>
> I'll provide such a patch.
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

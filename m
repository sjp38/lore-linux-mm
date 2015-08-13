Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id C7C4E6B0038
	for <linux-mm@kvack.org>; Thu, 13 Aug 2015 10:40:58 -0400 (EDT)
Received: by pdco4 with SMTP id o4so20591820pdc.3
        for <linux-mm@kvack.org>; Thu, 13 Aug 2015 07:40:58 -0700 (PDT)
Received: from mail-pa0-x22d.google.com (mail-pa0-x22d.google.com. [2607:f8b0:400e:c03::22d])
        by mx.google.com with ESMTPS id t2si4134159pdh.146.2015.08.13.07.40.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Aug 2015 07:40:58 -0700 (PDT)
Received: by pabyb7 with SMTP id yb7so38531858pab.0
        for <linux-mm@kvack.org>; Thu, 13 Aug 2015 07:40:57 -0700 (PDT)
Message-ID: <1439476856.7960.8.camel@edumazet-glaptop2.roam.corp.google.com>
Subject: Re: [PATCH] mm: make page pfmemalloc check more robust
From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 13 Aug 2015 07:40:56 -0700
In-Reply-To: <55CC5FA0.300@suse.cz>
References: <1439456364-4530-1-git-send-email-mhocko@kernel.org>
	 <55CC5FA0.300@suse.cz>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: mhocko@kernel.org, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Jiri Bohac <jbohac@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, "David S. Miller" <davem@davemloft.net>, LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org, Michal Hocko <mhocko@suse.com>

On Thu, 2015-08-13 at 11:13 +0200, Vlastimil Babka wrote:

> Given that this apparently isn't the first case of this localhost issue, 
> I wonder if network code should just clear skb->pfmemalloc during send 
> (or maybe just send over localhost). That would be probably easier than 
> distinguish the __skb_fill_page_desc() callers for send vs receive.

Would this still needed after this patch ?

It is sad we do not have a SNMP counter to at least count how often we
drop skb because pfmemalloc is set.

I'll provide such a patch.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

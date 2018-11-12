Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id 92F586B02B4
	for <linux-mm@kvack.org>; Mon, 12 Nov 2018 12:05:59 -0500 (EST)
Received: by mail-lj1-f197.google.com with SMTP id h10-v6so2887150ljk.18
        for <linux-mm@kvack.org>; Mon, 12 Nov 2018 09:05:59 -0800 (PST)
Received: from smtp7.iq.pl (smtp7.iq.pl. [86.111.240.244])
        by mx.google.com with ESMTPS id t12-v6si15771019ljh.211.2018.11.12.09.05.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Nov 2018 09:05:58 -0800 (PST)
Subject: Re: [PATCH 1/2] mm/page_alloc: free order-0 pages through PCP in
 page_frag_free()
References: <20181105085820.6341-1-aaron.lu@intel.com>
 <CAKgT0UdvYVTA8OjgLhXo9tRUOGikrCi3zJXSrqM0ZmeHb5P2mA@mail.gmail.com>
 <b8b1fbb7-9139-9455-69b8-8c1bed4f7c74@itcare.pl>
 <CAKgT0UdhcXF-ohPHPbg8onRjFabEMnbpXGmLm-27skCNzGKOgw@mail.gmail.com>
 <bd33633b-2f6c-0034-a130-38a8468531db@itcare.pl>
 <CAKgT0UeOBF0yPJLOTBBb3m7nTkmSDxzkCur+iGzJ++Y-jWaw9g@mail.gmail.com>
 <6edcec1a-eefa-7861-1af4-cdf7fa45184c@gmail.com>
From: =?UTF-8?Q?Pawe=c5=82_Staszewski?= <pstaszewski@itcare.pl>
Message-ID: <7a879d64-1d5a-ebda-8f44-b8d6bdd94afd@itcare.pl>
Date: Mon, 12 Nov 2018 18:06:01 +0100
MIME-Version: 1.0
In-Reply-To: <6edcec1a-eefa-7861-1af4-cdf7fa45184c@gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: pl
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>, Alexander Duyck <alexander.duyck@gmail.com>
Cc: aaron.lu@intel.com, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Netdev <netdev@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jesper Dangaard Brouer <brouer@redhat.com>, Tariq Toukan <tariqt@mellanox.com>, ilias.apalodimas@linaro.org, yoel@kviknet.dk, Mel Gorman <mgorman@techsingularity.net>, Saeed Mahameed <saeedm@mellanox.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, dave.hansen@linux.intel.com


W dniu 12.11.2018 oA 16:44, Eric Dumazet pisze:
>
> On 11/12/2018 07:30 AM, Alexander Duyck wrote:
>
>> It sounds to me like XDP would probably be your best bet. With that
>> you could probably get away with smaller ring sizes, higher interrupt
>> rates, and get the advantage of it batching the Tx without having to
>> drop packets.
> Add to this that with XDP (or anything lowering per packet processing costs)
> you can reduce number of cpus/queues, get better latencies, and bigger TX batches.

Yes for sure - the best for my use case will be to implement XDP :)

But for real life not test lab use programs like xdp_fwd need to be 
extended for minimal information needed from IP router - like counters 
and some aditional debug for traffic like sniffing / sampling for ddos 
detection.

And that is rly minimum needed - for routing IP traffic with XDP

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 31D376B029D
	for <linux-mm@kvack.org>; Mon, 12 Nov 2018 10:44:22 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id k14-v6so7444064pls.21
        for <linux-mm@kvack.org>; Mon, 12 Nov 2018 07:44:22 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id bj10-v6sor19431749plb.25.2018.11.12.07.44.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 12 Nov 2018 07:44:21 -0800 (PST)
Subject: Re: [PATCH 1/2] mm/page_alloc: free order-0 pages through PCP in
 page_frag_free()
References: <20181105085820.6341-1-aaron.lu@intel.com>
 <CAKgT0UdvYVTA8OjgLhXo9tRUOGikrCi3zJXSrqM0ZmeHb5P2mA@mail.gmail.com>
 <b8b1fbb7-9139-9455-69b8-8c1bed4f7c74@itcare.pl>
 <CAKgT0UdhcXF-ohPHPbg8onRjFabEMnbpXGmLm-27skCNzGKOgw@mail.gmail.com>
 <bd33633b-2f6c-0034-a130-38a8468531db@itcare.pl>
 <CAKgT0UeOBF0yPJLOTBBb3m7nTkmSDxzkCur+iGzJ++Y-jWaw9g@mail.gmail.com>
From: Eric Dumazet <eric.dumazet@gmail.com>
Message-ID: <6edcec1a-eefa-7861-1af4-cdf7fa45184c@gmail.com>
Date: Mon, 12 Nov 2018 07:44:18 -0800
MIME-Version: 1.0
In-Reply-To: <CAKgT0UeOBF0yPJLOTBBb3m7nTkmSDxzkCur+iGzJ++Y-jWaw9g@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Duyck <alexander.duyck@gmail.com>, =?UTF-8?Q?Pawe=c5=82_Staszewski?= <pstaszewski@itcare.pl>
Cc: aaron.lu@intel.com, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Netdev <netdev@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jesper Dangaard Brouer <brouer@redhat.com>, Eric Dumazet <eric.dumazet@gmail.com>, Tariq Toukan <tariqt@mellanox.com>, ilias.apalodimas@linaro.org, yoel@kviknet.dk, Mel Gorman <mgorman@techsingularity.net>, Saeed Mahameed <saeedm@mellanox.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, dave.hansen@linux.intel.com



On 11/12/2018 07:30 AM, Alexander Duyck wrote:

> It sounds to me like XDP would probably be your best bet. With that
> you could probably get away with smaller ring sizes, higher interrupt
> rates, and get the advantage of it batching the Tx without having to
> drop packets.

Add to this that with XDP (or anything lowering per packet processing costs)
you can reduce number of cpus/queues, get better latencies, and bigger TX batches.

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1C6986B000A
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 18:11:22 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id n19-v6so1720282pgv.14
        for <linux-mm@kvack.org>; Thu, 26 Jul 2018 15:11:22 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id f40-v6si2116676plb.504.2018.07.26.15.11.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Jul 2018 15:11:20 -0700 (PDT)
Date: Thu, 26 Jul 2018 15:11:18 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] [PATCH] mm: disable preemption before swapcache_free
Message-Id: <20180726151118.db0cf8016e79bed849e549f9@linux-foundation.org>
In-Reply-To: <20180726150323057627100@wingtech.com>
References: <2018072514375722198958@wingtech.com>
	<20180725141643.6d9ba86a9698bc2580836618@linux-foundation.org>
	<2018072610214038358990@wingtech.com>
	<20180726060640.GQ28386@dhcp22.suse.cz>
	<20180726150323057627100@wingtech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "zhaowuyun@wingtech.com" <zhaowuyun@wingtech.com>
Cc: Michal Hocko <mhocko@kernel.org>, mgorman <mgorman@techsingularity.net>, minchan <minchan@kernel.org>, vinmenon <vinmenon@codeaurora.org>, hannes <hannes@cmpxchg.org>, "hillf.zj" <hillf.zj@alibaba-inc.com>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>

On Thu, 26 Jul 2018 15:03:23 +0800 "zhaowuyun@wingtech.com" <zhaowuyun@wingtech.com> wrote:

> >On Thu 26-07-18 10:21:40, zhaowuyun@wingtech.com wrote:
> >[...]
> >> Our project really needs a fix to this issue
> >
> >Could you be more specific why? My understanding is that RT tasks
> >usually have all the memory mlocked otherwise all the real time
> >expectations are gone already.
> >--
> >Michal Hocko
> >SUSE Labs 
> 
> 
> The RT thread is created by a process with normal priority, and the process was sleep, 
> then some task needs the RT thread to do something, so the process create this thread, and set it to RT policy.
> I think that is the reason why RT task would read the swap.

A simpler bandaid might be to replace the cond_resched() with msleep(1).

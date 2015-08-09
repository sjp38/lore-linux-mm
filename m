Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 8FCA46B0253
	for <linux-mm@kvack.org>; Sun,  9 Aug 2015 06:51:53 -0400 (EDT)
Received: by wibxm9 with SMTP id xm9so115760258wib.1
        for <linux-mm@kvack.org>; Sun, 09 Aug 2015 03:51:53 -0700 (PDT)
Received: from mail-wi0-x229.google.com (mail-wi0-x229.google.com. [2a00:1450:400c:c05::229])
        by mx.google.com with ESMTPS id ot4si31451976wjc.143.2015.08.09.03.51.51
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 09 Aug 2015 03:51:52 -0700 (PDT)
Received: by wibxm9 with SMTP id xm9so115759918wib.1
        for <linux-mm@kvack.org>; Sun, 09 Aug 2015 03:51:51 -0700 (PDT)
Message-ID: <1439117508.21378.8.camel@gmail.com>
Subject: Re: [hack] sched: create PREEMPT_VOLUNTARY_RT and some RT specific
 resched points
From: Mike Galbraith <umgwanakikbuti@gmail.com>
Date: Sun, 09 Aug 2015 12:51:48 +0200
In-Reply-To: <1439112337.5906.43.camel@gmail.com>
References: <1437688476-3399-3-git-send-email-sbaugh@catern.com>
	 <20150724070420.GF4103@dhcp22.suse.cz>
	 <20150724165627.GA3458@Sligo.logfs.org>
	 <20150727070840.GB11317@dhcp22.suse.cz>
	 <20150727151814.GR9641@Sligo.logfs.org>
	 <20150728133254.GI24972@dhcp22.suse.cz>
	 <20150728170844.GY9641@Sligo.logfs.org>
	 <20150729095439.GD15801@dhcp22.suse.cz>
	 <1438269775.23663.58.camel@gmail.com>
	 <20150730165803.GA17882@Sligo.logfs.org>
	 <1438282521.6432.53.camel@gmail.com> <1439112337.5906.43.camel@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?ISO-8859-1?Q?J=F6rn?= Engel <joern@purestorage.com>
Cc: Michal Hocko <mhocko@kernel.org>, Spencer Baugh <sbaugh@catern.com>, Toshi Kani <toshi.kani@hp.com>, Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>, Joern Engel <joern@logfs.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Shachar Raindel <raindel@mellanox.com>, Boaz Harrosh <boaz@plexistor.com>, Andy Lutomirski <luto@amacapital.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrey Ryabinin <a.ryabinin@samsung.com>, Roman Pen <r.peniaev@gmail.com>, Andrey Konovalov <adech.fo@gmail.com>, Eric Dumazet <edumazet@google.com>, Dmitry Vyukov <dvyukov@google.com>, Rob Jones <rob.jones@codethink.co.uk>, WANG Chao <chaowang@redhat.com>, open list <linux-kernel@vger.kernel.org>, "open
 list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, Spencer Baugh <Spencer.baugh@purestorage.com>, Peter Zijlstra <peterz@infradead.org>

Damn, the hunk below was supposed to go away before hack escaped.

The whole thing is just a "could we maybe...", but just in case anybody
plays with it, that hunk proved to be a bad idea, kill it.

> --- a/kernel/softirq.c
> +++ b/kernel/softirq.c
> @@ -280,6 +280,8 @@ asmlinkage __visible void __do_softirq(v
>  		}
>  		h++;
>  		pending >>= softirq_bit;
> +		if (need_resched_rt() && current != this_cpu_ksoftirqd())
> +			break;



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

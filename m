Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id C459A6B000E
	for <linux-mm@kvack.org>; Tue,  6 Mar 2018 16:48:57 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id s21so489939ioa.7
        for <linux-mm@kvack.org>; Tue, 06 Mar 2018 13:48:57 -0800 (PST)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id z6si10951982iod.214.2018.03.06.13.48.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Mar 2018 13:48:56 -0800 (PST)
Subject: Re: [PATCH] mm: might_sleep warning
References: <20180306192022.28289-1-pasha.tatashin@oracle.com>
 <20180306123655.957e5b6b20b200505544ea7a@linux-foundation.org>
 <CAGM2rea1raxsXDkqZgmmdBiuywp1M3y1p++=J893VJDgGDWLnQ@mail.gmail.com>
 <20180306125604.c394a25a50cae0e36c546855@linux-foundation.org>
 <CAGM2rebb9FdceEBO2GfJ7BKf=fEf8p86Yc1vCq4eZyyB0Me+DA@mail.gmail.com>
 <20180306132129.45b395d9732b6360fa0b600d@linux-foundation.org>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Message-ID: <a90aa8fc-0612-3107-93c6-9e4b706785db@oracle.com>
Date: Tue, 6 Mar 2018 16:48:31 -0500
MIME-Version: 1.0
In-Reply-To: <20180306132129.45b395d9732b6360fa0b600d@linux-foundation.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Steven Sistare <steven.sistare@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Masayoshi Mizuma <m.mizuma@jp.fujitsu.com>, Michal Hocko <mhocko@suse.com>, Catalin Marinas <catalin.marinas@arm.com>, AKASHI Takahiro <takahiro.akashi@linaro.org>, Gioh Kim <gi-oh.kim@profitbricks.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Yaowei Bai <baiyaowei@cmss.chinamobile.com>, Wei Yang <richard.weiyang@gmail.com>, Paul Burton <paul.burton@mips.com>, Miles Chen <miles.chen@mediatek.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

> That's why page_alloc_init_late() needs spin_lock_irq().  If a CPU is
> holding deferred_zone_grow_lock with enabled interrupts and an
> interrupt comes in on that CPU and the CPU runs deferred_grow_zone() in
> its interrupt handler, we deadlock.
> 
> lockdep knows about this bug and should have reported it.
> 

I see what you are saying. Yes you are correct, we need spin_lock_irq() 
in page_alloc_init_late(). I will update the patch. I am not sure why 
lockdep has not reported it. May be it is initialized after this code is 
executed?

Thank you,
Pavel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

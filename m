Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8115F6B02F3
	for <linux-mm@kvack.org>; Tue, 25 Jul 2017 21:30:30 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id k72so69564387pfj.1
        for <linux-mm@kvack.org>; Tue, 25 Jul 2017 18:30:30 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id q10si9430020pli.45.2017.07.25.18.30.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jul 2017 18:30:29 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -mm -v3 1/6] mm, swap: Add swap cache statistics sysfs interface
References: <20170725015151.19502-1-ying.huang@intel.com>
	<20170725015151.19502-2-ying.huang@intel.com>
	<1501016754.26846.22.camel@redhat.com>
Date: Wed, 26 Jul 2017 09:30:26 +0800
In-Reply-To: <1501016754.26846.22.camel@redhat.com> (Rik van Riel's message of
	"Tue, 25 Jul 2017 17:05:54 -0400")
Message-ID: <87h8y0gf2l.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Fengguang Wu <fengguang.wu@intel.com>, Tim Chen <tim.c.chen@intel.com>, Dave Hansen <dave.hansen@intel.com>

Hi, Rik,

Rik van Riel <riel@redhat.com> writes:

> On Tue, 2017-07-25 at 09:51 +0800, Huang, Ying wrote:
>> From: Huang Ying <ying.huang@intel.com>
>> 
>> The swap cache stats could be gotten only via sysrq, which isn't
>> convenient in some situation.A A So the sysfs interface of swap cache
>> stats is added for that.A A The added sysfs directories/files are as
>> follow,
>> 
>> /sys/kernel/mm/swap
>> /sys/kernel/mm/swap/cache_find_total
>> /sys/kernel/mm/swap/cache_find_success
>> /sys/kernel/mm/swap/cache_add
>> /sys/kernel/mm/swap/cache_del
>> /sys/kernel/mm/swap/cache_pages
>> 
> What is the advantage of this vs new fields in
> /proc/vmstat, which is where most of the VM
> statistics seem to live?

As proposed by Andrew, will use debugfs for them, because they are
mostly developer related.

Best Regards,
Huang, Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

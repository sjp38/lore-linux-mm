Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 086CA6B02C3
	for <linux-mm@kvack.org>; Tue, 25 Jul 2017 21:29:53 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id v190so196264470pgv.12
        for <linux-mm@kvack.org>; Tue, 25 Jul 2017 18:29:53 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id d2si9328510pln.443.2017.07.25.18.29.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jul 2017 18:29:51 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -mm -v3 1/6] mm, swap: Add swap cache statistics sysfs interface
References: <20170725015151.19502-1-ying.huang@intel.com>
	<20170725015151.19502-2-ying.huang@intel.com>
	<20170725134247.71e77cb68695cb351e389119@linux-foundation.org>
Date: Wed, 26 Jul 2017 09:29:48 +0800
In-Reply-To: <20170725134247.71e77cb68695cb351e389119@linux-foundation.org>
	(Andrew Morton's message of "Tue, 25 Jul 2017 13:42:47 -0700")
Message-ID: <87lgncgf3n.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Huang, Ying" <ying.huang@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Fengguang Wu <fengguang.wu@intel.com>, Tim Chen <tim.c.chen@intel.com>, Dave Hansen <dave.hansen@intel.com>

Andrew Morton <akpm@linux-foundation.org> writes:

> On Tue, 25 Jul 2017 09:51:46 +0800 "Huang, Ying" <ying.huang@intel.com> wrote:
>
>> The swap cache stats could be gotten only via sysrq, which isn't
>> convenient in some situation.  So the sysfs interface of swap cache
>> stats is added for that.  The added sysfs directories/files are as
>> follow,
>> 
>> /sys/kernel/mm/swap
>> /sys/kernel/mm/swap/cache_find_total
>> /sys/kernel/mm/swap/cache_find_success
>> /sys/kernel/mm/swap/cache_add
>> /sys/kernel/mm/swap/cache_del
>> /sys/kernel/mm/swap/cache_pages
>
> We should document this somewhere.  Documentation/ABI/ is the formal
> place for sysfs files, but nobody will think to look there for VM
> things, so perhaps place a pointer to the Documentation/ABI/ files
> within Documentation/vm somewhere, only there isn't an appropriate
> Documentation/vm file ;)
>
> Or just put all these things in debugfs.  These are pretty specialized
> things and appear to be developer-only files of short-term interest?

Yes.  Debugfs should be better place for these.  Will update it in the
next version.

And I also introduced sysfs interface in [2/6] and [5/6]

/sys/kernel/mm/swap/ra_hits
/sys/kernel/mm/swap/ra_total

/sys/kernel/mm/swap/vma_ra_enabled
/sys/kernel/mm/swap/vma_ra_max_order

Will add ABI document for them.

Best Regards,
Huang, Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

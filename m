Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4D38A6B0069
	for <linux-mm@kvack.org>; Mon, 28 Nov 2016 09:49:20 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id bk3so21037456wjc.4
        for <linux-mm@kvack.org>; Mon, 28 Nov 2016 06:49:20 -0800 (PST)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id d81si26080862wmc.164.2016.11.28.06.49.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Nov 2016 06:49:19 -0800 (PST)
Received: by mail-wm0-f65.google.com with SMTP id u144so19349133wmu.0
        for <linux-mm@kvack.org>; Mon, 28 Nov 2016 06:49:19 -0800 (PST)
Date: Mon, 28 Nov 2016 15:49:17 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC 0/2] Add interface let ZRAM close swap cache
Message-ID: <20161128144917.GQ14788@dhcp22.suse.cz>
References: <1480062313-7361-1-git-send-email-zhuhui@xiaomi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1480062313-7361-1-git-send-email-zhuhui@xiaomi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hui Zhu <zhuhui@xiaomi.com>
Cc: minchan@kernel.org, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, dan.j.williams@intel.com, jthumshirn@suse.de, akpm@linux-foundation.org, re.emese@gmail.com, andriy.shevchenko@linux.intel.com, vishal.l.verma@intel.com, hannes@cmpxchg.org, mgorman@techsingularity.net, vbabka@suse.cz, vdavydov.dev@gmail.com, kirill.shutemov@linux.intel.com, ying.huang@intel.com, yang.shi@linaro.org, dave.hansen@linux.intel.com, willy@linux.intel.com, vkuznets@redhat.com, vitalywool@gmail.com, jmarchan@redhat.com, lstoakes@gmail.com, geliangtang@163.com, viro@zeniv.linux.org.uk, hughd@google.com, riel@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, teawater@gmail.com

On Fri 25-11-16 16:25:11, Hui Zhu wrote:
> SWAP will keep before swap cache before swap space get full.  It will
> make swap space cannot be freed.  It is harmful to the system that use
> ZRAM because its space use memory too.

I have hard time to follow what you are trying to say here. Could you be
more specific about what is the actual problem?

> This two patches will add a sysfs switch to ZRAM that open or close swap
> cache without check the swap space.

I find this a crude hack to be honest. Please make sure to describe why
the swap cache stays in the way and why this is not problem in other
setups.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

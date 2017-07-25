Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id AA3DC6B025F
	for <linux-mm@kvack.org>; Tue, 25 Jul 2017 16:42:50 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id x64so8076771wmg.11
        for <linux-mm@kvack.org>; Tue, 25 Jul 2017 13:42:50 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id a101si16479249wrc.78.2017.07.25.13.42.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jul 2017 13:42:49 -0700 (PDT)
Date: Tue, 25 Jul 2017 13:42:47 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH -mm -v3 1/6] mm, swap: Add swap cache statistics sysfs
 interface
Message-Id: <20170725134247.71e77cb68695cb351e389119@linux-foundation.org>
In-Reply-To: <20170725015151.19502-2-ying.huang@intel.com>
References: <20170725015151.19502-1-ying.huang@intel.com>
	<20170725015151.19502-2-ying.huang@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Fengguang Wu <fengguang.wu@intel.com>, Tim Chen <tim.c.chen@intel.com>, Dave Hansen <dave.hansen@intel.com>

On Tue, 25 Jul 2017 09:51:46 +0800 "Huang, Ying" <ying.huang@intel.com> wrote:

> The swap cache stats could be gotten only via sysrq, which isn't
> convenient in some situation.  So the sysfs interface of swap cache
> stats is added for that.  The added sysfs directories/files are as
> follow,
> 
> /sys/kernel/mm/swap
> /sys/kernel/mm/swap/cache_find_total
> /sys/kernel/mm/swap/cache_find_success
> /sys/kernel/mm/swap/cache_add
> /sys/kernel/mm/swap/cache_del
> /sys/kernel/mm/swap/cache_pages

We should document this somewhere.  Documentation/ABI/ is the formal
place for sysfs files, but nobody will think to look there for VM
things, so perhaps place a pointer to the Documentation/ABI/ files
within Documentation/vm somewhere, only there isn't an appropriate
Documentation/vm file ;)

Or just put all these things in debugfs.  These are pretty specialized
things and appear to be developer-only files of short-term interest?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

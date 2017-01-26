Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6CCED6B0033
	for <linux-mm@kvack.org>; Thu, 26 Jan 2017 16:52:56 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id 201so327254531pfw.5
        for <linux-mm@kvack.org>; Thu, 26 Jan 2017 13:52:56 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id p86si2499708pfk.75.2017.01.26.13.52.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Jan 2017 13:52:55 -0800 (PST)
Date: Thu, 26 Jan 2017 13:52:54 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/2] base/memory, hotplug: fix a kernel oops in
 show_valid_zones()
Message-Id: <20170126135254.cbd0bdbe3cdc5910c288ad32@linux-foundation.org>
In-Reply-To: <20170126214415.4509-3-toshi.kani@hpe.com>
References: <20170126214415.4509-1-toshi.kani@hpe.com>
	<20170126214415.4509-3-toshi.kani@hpe.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hpe.com>
Cc: gregkh@linuxfoundation.org, linux-mm@kvack.org, zhenzhang.zhang@huawei.com, arbab@linux.vnet.ibm.com, dan.j.williams@intel.com, abanman@sgi.com, rientjes@google.com, linux-kernel@vger.kernel.org

On Thu, 26 Jan 2017 14:44:15 -0700 Toshi Kani <toshi.kani@hpe.com> wrote:

> Reading a sysfs memoryN/valid_zones file leads to the following
> oops when the first page of a range is not backed by struct page.
> show_valid_zones() assumes that 'start_pfn' is always valid for
> page_zone().
> 
>  BUG: unable to handle kernel paging request at ffffea017a000000
>  IP: show_valid_zones+0x6f/0x160
> 
> Since test_pages_in_a_zone() already checks holes, extend this
> function to return 'valid_start' and 'valid_end' for a given range.
> show_valid_zones() then proceeds with the valid range.

This doesn't apply to current mainline due to changes in
zone_can_shift().  Please redo and resend.

Please also update the changelog to provide sufficient information for
others to decide which kernel(s) need the fix.  In particular: under
what circumstances will it occur?  On real machines which real people
own?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

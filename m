Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 30B2E6B0033
	for <linux-mm@kvack.org>; Wed, 11 Jan 2017 22:09:46 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id c73so19749902pfb.7
        for <linux-mm@kvack.org>; Wed, 11 Jan 2017 19:09:46 -0800 (PST)
Received: from out4433.biz.mail.alibaba.com (out4433.biz.mail.alibaba.com. [47.88.44.33])
        by mx.google.com with ESMTP id 3si7743898plo.4.2017.01.11.19.09.43
        for <linux-mm@kvack.org>;
        Wed, 11 Jan 2017 19:09:45 -0800 (PST)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <20170109163518.6001-1-mgorman@techsingularity.net> <20170109163518.6001-2-mgorman@techsingularity.net>
In-Reply-To: <20170109163518.6001-2-mgorman@techsingularity.net>
Subject: Re: [PATCH 1/4] mm, page_alloc: Split buffered_rmqueue
Date: Thu, 12 Jan 2017 11:09:30 +0800
Message-ID: <022201d26c81$4af8dc50$e0ea94f0$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Mel Gorman' <mgorman@techsingularity.net>, 'Jesper Dangaard Brouer' <brouer@redhat.com>
Cc: 'Linux Kernel' <linux-kernel@vger.kernel.org>, 'Linux-MM' <linux-mm@kvack.org>

On Tuesday, January 10, 2017 12:35 AM Mel Gorman wrote: 
> 
> buffered_rmqueue removes a page from a given zone and uses the per-cpu
> list for order-0. This is fine but a hypothetical caller that wanted
> multiple order-0 pages has to disable/reenable interrupts multiple
> times. This patch structures buffere_rmqueue such that it's relatively
> easy to build a bulk order-0 page allocator. There is no functional
> change.
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> ---
Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

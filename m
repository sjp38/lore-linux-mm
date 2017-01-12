Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id E0F976B0069
	for <linux-mm@kvack.org>; Wed, 11 Jan 2017 22:11:16 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id f144so19970225pfa.3
        for <linux-mm@kvack.org>; Wed, 11 Jan 2017 19:11:16 -0800 (PST)
Received: from out4440.biz.mail.alibaba.com (out4440.biz.mail.alibaba.com. [47.88.44.40])
        by mx.google.com with ESMTP id c16si7728247pfc.102.2017.01.11.19.11.14
        for <linux-mm@kvack.org>;
        Wed, 11 Jan 2017 19:11:15 -0800 (PST)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <20170109163518.6001-1-mgorman@techsingularity.net> <20170109163518.6001-3-mgorman@techsingularity.net>
In-Reply-To: <20170109163518.6001-3-mgorman@techsingularity.net>
Subject: Re: [PATCH 2/4] mm, page_alloc: Split alloc_pages_nodemask
Date: Thu, 12 Jan 2017 11:11:00 +0800
Message-ID: <022301d26c81$807332e0$815998a0$@alibaba-inc.com>
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
> alloc_pages_nodemask does a number of preperation steps that determine
> what zones can be used for the allocation depending on a variety of
> factors. This is fine but a hypothetical caller that wanted multiple
> order-0 pages has to do the preparation steps multiple times. This patch
> structures __alloc_pages_nodemask such that it's relatively easy to build
> a bulk order-0 page allocator. There is no functional change.
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> ---
Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

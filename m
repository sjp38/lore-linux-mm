Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 081326B0069
	for <linux-mm@kvack.org>; Wed, 11 Jan 2017 07:32:17 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id d75so108514703qkc.0
        for <linux-mm@kvack.org>; Wed, 11 Jan 2017 04:32:17 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 142si3664356qkf.77.2017.01.11.04.32.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Jan 2017 04:32:16 -0800 (PST)
Date: Wed, 11 Jan 2017 13:32:11 +0100
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH 2/4] mm, page_alloc: Split alloc_pages_nodemask
Message-ID: <20170111133211.39132706@redhat.com>
In-Reply-To: <20170109163518.6001-3-mgorman@techsingularity.net>
References: <20170109163518.6001-1-mgorman@techsingularity.net>
	<20170109163518.6001-3-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, brouer@redhat.com

On Mon,  9 Jan 2017 16:35:16 +0000
Mel Gorman <mgorman@techsingularity.net> wrote:

> alloc_pages_nodemask does a number of preperation steps that determine
> what zones can be used for the allocation depending on a variety of
> factors. This is fine but a hypothetical caller that wanted multiple
> order-0 pages has to do the preparation steps multiple times. This patch
> structures __alloc_pages_nodemask such that it's relatively easy to build
> a bulk order-0 page allocator. There is no functional change.
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

Acked-by: Jesper Dangaard Brouer <brouer@redhat.com>

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

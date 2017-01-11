Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id B42A36B0033
	for <linux-mm@kvack.org>; Wed, 11 Jan 2017 07:31:17 -0500 (EST)
Received: by mail-qt0-f197.google.com with SMTP id f4so106211645qte.1
        for <linux-mm@kvack.org>; Wed, 11 Jan 2017 04:31:17 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b38si3663547qte.185.2017.01.11.04.31.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Jan 2017 04:31:17 -0800 (PST)
Date: Wed, 11 Jan 2017 13:31:10 +0100
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH 1/4] mm, page_alloc: Split buffered_rmqueue
Message-ID: <20170111133110.52fcda6f@redhat.com>
In-Reply-To: <20170109163518.6001-2-mgorman@techsingularity.net>
References: <20170109163518.6001-1-mgorman@techsingularity.net>
	<20170109163518.6001-2-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, brouer@redhat.com

On Mon,  9 Jan 2017 16:35:15 +0000
Mel Gorman <mgorman@techsingularity.net> wrote:

> buffered_rmqueue removes a page from a given zone and uses the per-cpu
> list for order-0. This is fine but a hypothetical caller that wanted
> multiple order-0 pages has to disable/reenable interrupts multiple
> times. This patch structures buffere_rmqueue such that it's relatively
> easy to build a bulk order-0 page allocator. There is no functional
> change.
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

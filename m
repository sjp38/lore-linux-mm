Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f42.google.com (mail-pb0-f42.google.com [209.85.160.42])
	by kanga.kvack.org (Postfix) with ESMTP id 81F0E6B0031
	for <linux-mm@kvack.org>; Wed, 18 Sep 2013 21:04:30 -0400 (EDT)
Received: by mail-pb0-f42.google.com with SMTP id un15so7773671pbc.1
        for <linux-mm@kvack.org>; Wed, 18 Sep 2013 18:04:30 -0700 (PDT)
Received: by mail-pd0-f171.google.com with SMTP id g10so7758580pdj.16
        for <linux-mm@kvack.org>; Wed, 18 Sep 2013 18:04:27 -0700 (PDT)
Date: Wed, 18 Sep 2013 18:04:25 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RESEND PATCH] mm/mempolicy: use NUMA_NO_NODE
In-Reply-To: <5237AB84.9000404@huawei.com>
Message-ID: <alpine.DEB.2.02.1309181804160.22497@chino.kir.corp.google.com>
References: <5237AB84.9000404@huawei.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jianguo Wu <wujianguo@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Cody P Schafer <cody@linux.vnet.ibm.com>

On Tue, 17 Sep 2013, Jianguo Wu wrote:

> Use more appropriate NUMA_NO_NODE instead of -1
> 
> Signed-off-by: Jianguo Wu <wujianguo@huawei.com>
> Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

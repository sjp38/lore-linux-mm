Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 1CEE66B004D
	for <linux-mm@kvack.org>; Mon, 16 Sep 2013 12:19:35 -0400 (EDT)
Received: by mail-ob0-f177.google.com with SMTP id wp18so3980689obc.8
        for <linux-mm@kvack.org>; Mon, 16 Sep 2013 09:19:34 -0700 (PDT)
Message-ID: <52372F9A.1080102@gmail.com>
Date: Mon, 16 Sep 2013 12:19:38 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/mempolicy: use NUMA_NO_NODE
References: <5236FF32.60503@huawei.com>
In-Reply-To: <5236FF32.60503@huawei.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jianguo Wu <wujianguo@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kosaki.motohiro@gmail.com

(9/16/13 8:53 AM), Jianguo Wu wrote:
> Use more appropriate NUMA_NO_NODE instead of -1
>
> Signed-off-by: Jianguo Wu <wujianguo@huawei.com>
> ---
>   mm/mempolicy.c |   10 +++++-----
>   1 files changed, 5 insertions(+), 5 deletions(-)

I think this patch don't make any functional change, right?

Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

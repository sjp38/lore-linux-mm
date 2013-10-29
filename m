Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f46.google.com (mail-pb0-f46.google.com [209.85.160.46])
	by kanga.kvack.org (Postfix) with ESMTP id 70F796B0031
	for <linux-mm@kvack.org>; Tue, 29 Oct 2013 02:42:06 -0400 (EDT)
Received: by mail-pb0-f46.google.com with SMTP id un4so1802779pbc.5
        for <linux-mm@kvack.org>; Mon, 28 Oct 2013 23:42:06 -0700 (PDT)
Received: from psmtp.com ([74.125.245.103])
        by mx.google.com with SMTP id it5si13984373pbc.305.2013.10.28.23.42.04
        for <linux-mm@kvack.org>;
        Mon, 28 Oct 2013 23:42:05 -0700 (PDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 7D43F3EE0C2
	for <linux-mm@kvack.org>; Tue, 29 Oct 2013 15:42:02 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6EC5545DE3E
	for <linux-mm@kvack.org>; Tue, 29 Oct 2013 15:42:02 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 52BD245DE54
	for <linux-mm@kvack.org>; Tue, 29 Oct 2013 15:42:02 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 282E01DB804B
	for <linux-mm@kvack.org>; Tue, 29 Oct 2013 15:42:02 +0900 (JST)
Received: from m1001.s.css.fujitsu.com (m1001.s.css.fujitsu.com [10.240.81.139])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 838DC1DB804F
	for <linux-mm@kvack.org>; Tue, 29 Oct 2013 15:42:01 +0900 (JST)
Message-ID: <526F58B5.7020503@jp.fujitsu.com>
Date: Tue, 29 Oct 2013 02:41:57 -0400
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: cma: free cma page to buddy instead of being cpu
 hot page
References: <1382960569-6564-1-git-send-email-zhang.mingjun@linaro.org> <20131029045430.GE17038@bbox>
In-Reply-To: <20131029045430.GE17038@bbox>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: minchan@kernel.org, zhang.mingjun@linaro.org
Cc: m.szyprowski@samsung.com, akpm@linux-foundation.org, mgorman@suse.de, haojian.zhuang@linaro.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, troy.zhangmingjun@linaro.org

> The concern is likely/unlikely usage is proper in this code peice.
> If we don't use memory isolation, the code path is used for only
> MIGRATE_RESERVE which is very rare allocation in normal workload.
> 
> Even, in memory isolation environement, I'm not sure how many
> CMA/HOTPLUG is used compared to normal alloc/free.
> So, I think below is more proper?
> 
> if (unlikely(migratetype >= MIGRATE_PCPTYPES)) {
>         if (is_migrate_isolate(migratetype) || is_migrate_cma(migratetype))
> 
> I know it's an another topic but I'd like to disucss it in this time because
> we will forget such trivial thing later, again.

I completely agree with this.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id CC8EC6B0005
	for <linux-mm@kvack.org>; Tue,  5 Jul 2016 03:24:53 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id u201so281574317oie.2
        for <linux-mm@kvack.org>; Tue, 05 Jul 2016 00:24:53 -0700 (PDT)
Received: from out4133-130.mail.aliyun.com (out4133-130.mail.aliyun.com. [42.120.133.130])
        by mx.google.com with ESMTP id s103si2194716ioi.49.2016.07.05.00.24.52
        for <linux-mm@kvack.org>;
        Tue, 05 Jul 2016 00:24:53 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <00ee01d1d68e$183854a0$48a8fde0$@alibaba-inc.com>
In-Reply-To: <00ee01d1d68e$183854a0$48a8fde0$@alibaba-inc.com>
Subject: Re: [PATCH 30/31] mm, vmstat: print node-based stats in zoneinfo file
Date: Tue, 05 Jul 2016 15:24:49 +0800
Message-ID: <00ef01d1d68e$51247960$f36d6c20$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

> 
> There are a number of stats that were previously accessible via zoneinfo
> that are now invisible. While it is possible to create a new file for the
> node stats, this may be missed by users. Instead this patch prints the
> stats under the first populated zone in /proc/zoneinfo.
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> ---
Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>

>  mm/vmstat.c | 24 ++++++++++++++++++++++++
>  1 file changed, 24 insertions(+)
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

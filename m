Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f172.google.com (mail-ea0-f172.google.com [209.85.215.172])
	by kanga.kvack.org (Postfix) with ESMTP id 1D3E36B0036
	for <linux-mm@kvack.org>; Fri,  7 Feb 2014 08:16:47 -0500 (EST)
Received: by mail-ea0-f172.google.com with SMTP id l9so1314034eaj.31
        for <linux-mm@kvack.org>; Fri, 07 Feb 2014 05:16:46 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id x7si8178529eef.198.2014.02.07.05.16.45
        for <linux-mm@kvack.org>;
        Fri, 07 Feb 2014 05:16:45 -0800 (PST)
Message-ID: <52F4DCB0.7050500@redhat.com>
Date: Fri, 07 Feb 2014 08:16:32 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 5/9] mm: Mark functions as static in migrate.c
References: <a7658fc8f2ab015bffe83de1448cc3db79d2a9fc.1391167128.git.rashika.kheria@gmail.com> <2f62d7bb34ad1797b2990524239d4de90f8073a4.1391167128.git.rashika.kheria@gmail.com>
In-Reply-To: <2f62d7bb34ad1797b2990524239d4de90f8073a4.1391167128.git.rashika.kheria@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rashika Kheria <rashika.kheria@gmail.com>, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Ingo Molnar <mingo@kernel.org>, linux-mm@kvack.org, josh@joshtriplett.org

On 02/07/2014 07:08 AM, Rashika Kheria wrote:
> Mark functions as static in migrate.c because they are not used outside
> this file.
> 
> This eliminates the following warnings in mm/migrate.c:
> mm/migrate.c:1595:6: warning: no previous prototype for a??numamigrate_update_ratelimita?? [-Wmissing-prototypes]
> mm/migrate.c:1619:5: warning: no previous prototype for a??numamigrate_isolate_pagea?? [-Wmissing-prototypes]
> 
> Signed-off-by: Rashika Kheria <rashika.kheria@gmail.com>
> Reviewed-by: Josh Triplett <josh@joshtriplett.org>

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

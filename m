Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 09E8A6B026A
	for <linux-mm@kvack.org>; Wed, 31 Oct 2018 09:52:45 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id 3-v6so5107860plc.18
        for <linux-mm@kvack.org>; Wed, 31 Oct 2018 06:52:45 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id i13-v6si27207732pgd.311.2018.10.31.06.52.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Oct 2018 06:52:43 -0700 (PDT)
Date: Wed, 31 Oct 2018 09:52:42 -0400
From: Sasha Levin <sashal@kernel.org>
Subject: Re: [PATCH 4.18] Revert "mm: slowly shrink slabs with a relatively
 small number of objects"
Message-ID: <20181031135242.GI194472@sasha-vm>
References: <20181026111859.23807-1-sashal@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20181026111859.23807-1-sashal@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: gregkh@linuxfoundation.org
Cc: stable@vger.kernel.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org

On Fri, Oct 26, 2018 at 07:18:59AM -0400, Sasha Levin wrote:
>This reverts commit 62aad93f09c1952ede86405894df1b22012fd5ab.
>
>Which was upstream commit 172b06c32b94 ("mm: slowly shrink slabs with a
>relatively small number of objects").
>
>The upstream commit was found to cause regressions. While there is a
>proposed fix upstream, revent this patch from stable trees for now as
>testing the fix will take some time.
>
>Signed-off-by: Sasha Levin <sashal@kernel.org>
>---
> mm/vmscan.c | 11 -----------
> 1 file changed, 11 deletions(-)
>
>diff --git a/mm/vmscan.c b/mm/vmscan.c
>index fc0436407471..03822f86f288 100644
>--- a/mm/vmscan.c
>+++ b/mm/vmscan.c
>@@ -386,17 +386,6 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
> 	delta = freeable >> priority;
> 	delta *= 4;
> 	do_div(delta, shrinker->seeks);
>-
>-	/*
>-	 * Make sure we apply some minimal pressure on default priority
>-	 * even on small cgroups. Stale objects are not only consuming memory
>-	 * by themselves, but can also hold a reference to a dying cgroup,
>-	 * preventing it from being reclaimed. A dying cgroup with all
>-	 * corresponding structures like per-cpu stats and kmem caches
>-	 * can be really big, so it may lead to a significant waste of memory.
>-	 */
>-	delta = max_t(unsigned long long, delta, min(freeable, batch_size));
>-
> 	total_scan += delta;
> 	if (total_scan < 0) {
> 		pr_err("shrink_slab: %pF negative objects to delete nr=%ld\n",

I've queued it up for 4.18.

--
Thanks,
Sasha

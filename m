Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id 301186B0033
	for <linux-mm@kvack.org>; Thu,  2 Feb 2017 06:28:43 -0500 (EST)
Received: by mail-ot0-f200.google.com with SMTP id 65so11510212otq.2
        for <linux-mm@kvack.org>; Thu, 02 Feb 2017 03:28:43 -0800 (PST)
Received: from mail-oi0-x242.google.com (mail-oi0-x242.google.com. [2607:f8b0:4003:c06::242])
        by mx.google.com with ESMTPS id e186si9335651oic.91.2017.02.02.03.28.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Feb 2017 03:28:42 -0800 (PST)
Received: by mail-oi0-x242.google.com with SMTP id w144so953983oiw.1
        for <linux-mm@kvack.org>; Thu, 02 Feb 2017 03:28:42 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170202104422.GF22806@dhcp22.suse.cz>
References: <1485504817-3124-1-git-send-email-vinmenon@codeaurora.org>
 <1485853328-7672-1-git-send-email-vinmenon@codeaurora.org> <20170202104422.GF22806@dhcp22.suse.cz>
From: vinayak menon <vinayakm.list@gmail.com>
Date: Thu, 2 Feb 2017 16:58:41 +0530
Message-ID: <CAOaiJ-mtg2c+0sbs4gdTF3T2Jkp=M7jObZFXZsfS3wb2gp0Fsg@mail.gmail.com>
Subject: Re: [PATCH 1/2 v3] mm: vmscan: do not pass reclaimed slab to vmpressure
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Vinayak Menon <vinmenon@codeaurora.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, mgorman@techsingularity.net, vbabka@suse.cz, Rik van Riel <riel@redhat.com>, vdavydov.dev@gmail.com, anton.vorontsov@linaro.org, Minchan Kim <minchan@kernel.org>, shashim@codeaurora.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-kernel@vger.kernel.org

On Thu, Feb 2, 2017 at 4:14 PM, Michal Hocko <mhocko@kernel.org> wrote:

>
> We usually refer to the culprit comment as
> Fixes: 6b4f7799c6a5 ("mm: vmscan: invoke slab shrinkers from shrink_zone()")
>
Thanks for pointing that out Michal. I see that added to the version
of patch in mmotm.

> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id C877A6B0005
	for <linux-mm@kvack.org>; Thu, 16 Jun 2016 00:21:51 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id a69so83533983pfa.1
        for <linux-mm@kvack.org>; Wed, 15 Jun 2016 21:21:51 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id pt5si6003426pac.51.2016.06.15.21.21.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Jun 2016 21:21:50 -0700 (PDT)
Subject: Re: [PATCH v1 0/3] per-process reclaim
References: <1465804259-29345-1-git-send-email-minchan@kernel.org>
 <8f2190f4-4388-0eb2-0ffc-b2190280b11a@codeaurora.org>
 <20160615005755.GD17127@bbox>
From: Vinayak Menon <vinmenon@codeaurora.org>
Message-ID: <5e33c94d-d580-2e80-6818-bfb55a9a8a48@codeaurora.org>
Date: Thu, 16 Jun 2016 09:51:41 +0530
MIME-Version: 1.0
In-Reply-To: <20160615005755.GD17127@bbox>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Redmond <u93410091@gmail.com>, "ZhaoJunmin Zhao(Junmin)" <zhaojunmin@huawei.com>, Juneho Choi <juno.choi@lge.com>, Sangwoo Park <sangwoo2.park@lge.com>, Chan Gyun Jeong <chan.jeong@lge.com>


On 6/15/2016 6:27 AM, Minchan Kim wrote:
>
> Yeb, I read Johannes's thread which suggests one-cgroup-per-app model.
> It does make sense to me. It is worth to try although I guess it's not
> easy to control memory usage on demand, not proactively.
> If we can do, maybe we don't need per-process reclaim policy which
> is rather coarse-grained model of reclaim POV.
> However, a concern with one-cgroup-per-app model is LRU list size
> of a cgroup is much smaller so how LRU aging works well and
> LRU churing(e.g., compaction) effect would be severe than old.
And I was thinking what would vmpressure mean and how to use it when cgroup is per task.
>
> I guess codeaurora tried memcg model for android.
> Could you share if you know something?
>
We tried, but had issues with charge migration and then Johannes suggested per task cgroup.
But that's not tried yet.

Thanks

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

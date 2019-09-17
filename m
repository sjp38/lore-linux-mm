Return-Path: <SRS0=uo52=XM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9A284C4CEC9
	for <linux-mm@archiver.kernel.org>; Tue, 17 Sep 2019 07:40:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 755AF20678
	for <linux-mm@archiver.kernel.org>; Tue, 17 Sep 2019 07:40:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 755AF20678
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0C6456B0003; Tue, 17 Sep 2019 03:40:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 076BB6B0005; Tue, 17 Sep 2019 03:40:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ECE846B0006; Tue, 17 Sep 2019 03:40:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0221.hostedemail.com [216.40.44.221])
	by kanga.kvack.org (Postfix) with ESMTP id CEC206B0003
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 03:40:07 -0400 (EDT)
Received: from smtpin09.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 6FE6F824CA35
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 07:40:07 +0000 (UTC)
X-FDA: 75943614054.09.glue39_107537fdc728
X-HE-Tag: glue39_107537fdc728
X-Filterd-Recvd-Size: 2169
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf32.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 07:40:06 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id DBCF3AD3A;
	Tue, 17 Sep 2019 07:40:04 +0000 (UTC)
Date: Tue, 17 Sep 2019 09:40:03 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Qian Cai <cai@lca.pw>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov.dev@gmail.com,
	cgroups@vger.kernel.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm/memcontrol: fix a -Wunused-function warning
Message-ID: <20190917074003.GA17727@dhcp22.suse.cz>
References: <1568648453-5482-1-git-send-email-cai@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1568648453-5482-1-git-send-email-cai@lca.pw>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000004, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 16-09-19 11:40:53, Qian Cai wrote:
> mem_cgroup_id_get() was introduced in the commit 73f576c04b94
> ("mm:memcontrol: fix cgroup creation failure after many small jobs").
> 
> Later, it no longer has any user since the commits,
> 
> 1f47b61fb407 ("mm: memcontrol: fix swap counter leak on swapout from offline cgroup")
> 58fa2a5512d9 ("mm: memcontrol: add sanity checks for memcg->id.ref on get/put")
> 
> so safe to remove it.
> 
> Signed-off-by: Qian Cai <cai@lca.pw>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/memcontrol.c | 5 -----
>  1 file changed, 5 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 9ec5e12486a7..9a375b376157 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -4675,11 +4675,6 @@ static void mem_cgroup_id_put_many(struct mem_cgroup *memcg, unsigned int n)
>  	}
>  }
>  
> -static inline void mem_cgroup_id_get(struct mem_cgroup *memcg)
> -{
> -	mem_cgroup_id_get_many(memcg, 1);
> -}
> -
>  static inline void mem_cgroup_id_put(struct mem_cgroup *memcg)
>  {
>  	mem_cgroup_id_put_many(memcg, 1);
> -- 
> 1.8.3.1

-- 
Michal Hocko
SUSE Labs


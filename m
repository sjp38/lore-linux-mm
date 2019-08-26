Return-Path: <SRS0=haCV=WW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 800BBC3A59E
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 08:30:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1D8D92087E
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 08:30:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=yandex-team.ru header.i=@yandex-team.ru header.b="PzP7Xz+0"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1D8D92087E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=yandex-team.ru
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 90F3A6B0546; Mon, 26 Aug 2019 04:30:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8BF846B0547; Mon, 26 Aug 2019 04:30:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7ADE46B0548; Mon, 26 Aug 2019 04:30:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0004.hostedemail.com [216.40.44.4])
	by kanga.kvack.org (Postfix) with ESMTP id 532B76B0546
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 04:30:34 -0400 (EDT)
Received: from smtpin02.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id E6E73824CA3B
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 08:30:33 +0000 (UTC)
X-FDA: 75863907546.02.sail22_21dc5b7bb4c5b
X-HE-Tag: sail22_21dc5b7bb4c5b
X-Filterd-Recvd-Size: 4979
Received: from forwardcorp1o.mail.yandex.net (forwardcorp1o.mail.yandex.net [95.108.205.193])
	by imf26.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 08:30:32 +0000 (UTC)
Received: from mxbackcorp1j.mail.yandex.net (mxbackcorp1j.mail.yandex.net [IPv6:2a02:6b8:0:1619::162])
	by forwardcorp1o.mail.yandex.net (Yandex) with ESMTP id ED3E42E09BB;
	Mon, 26 Aug 2019 11:30:29 +0300 (MSK)
Received: from smtpcorp1p.mail.yandex.net (smtpcorp1p.mail.yandex.net [2a02:6b8:0:1472:2741:0:8b6:10])
	by mxbackcorp1j.mail.yandex.net (nwsmtp/Yandex) with ESMTP id hHO564yDGf-UTcSVNUc;
	Mon, 26 Aug 2019 11:30:29 +0300
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=yandex-team.ru; s=default;
	t=1566808229; bh=LOCYjiT8FfunGZukLIK5K5NXyHYjruIoyJuaVRXWFmw=;
	h=In-Reply-To:Message-ID:From:Date:References:To:Subject:Cc;
	b=PzP7Xz+0fbmSFKmOl6qSc25qnWjMayfAIpLSoml9FZ8ZarWGHebheC5fEvxFDfPCt
	 dOCHjV3FaJj7JujDdJ1LFCKmF+JXBAuyH3WuQlZ4uoazgTMqz+hrN1fnRtPXmZs5HU
	 Cu9026sTL8hgP5UBrNPW6Lv6uBn23Bic/Z3aRXAM=
Authentication-Results: mxbackcorp1j.mail.yandex.net; dkim=pass header.i=@yandex-team.ru
Received: from dynamic-red.dhcp.yndx.net (dynamic-red.dhcp.yndx.net [2a02:6b8:0:40c:f558:a2a9:365e:6e19])
	by smtpcorp1p.mail.yandex.net (nwsmtp/Yandex) with ESMTPSA id ojm22rWDi5-USBaIVFe;
	Mon, 26 Aug 2019 11:30:29 +0300
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(Client certificate not present)
Subject: Re: [PATCH 03/14] lru/memcg: using per lruvec lock in
 un/lock_page_lru
To: Alex Shi <alex.shi@linux.alibaba.com>, cgroups@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 Andrew Morton <akpm@linux-foundation.org>,
 Mel Gorman <mgorman@techsingularity.net>, Tejun Heo <tj@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>,
 Vladimir Davydov <vdavydov.dev@gmail.com>, Hugh Dickins <hughd@google.com>
References: <1566294517-86418-1-git-send-email-alex.shi@linux.alibaba.com>
 <1566294517-86418-4-git-send-email-alex.shi@linux.alibaba.com>
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Message-ID: <936eb865-d8da-8e53-3e2b-6858c586aa49@yandex-team.ru>
Date: Mon, 26 Aug 2019 11:30:28 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <1566294517-86418-4-git-send-email-alex.shi@linux.alibaba.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-CA
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 20/08/2019 12.48, Alex Shi wrote:
> Now we repeatly assign the lruvec->pgdat in memcg. Will remove the
> assignment in lruvec getting function after very points are protected.
> 
> Signed-off-by: Alex Shi <alex.shi@linux.alibaba.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Tejun Heo <tj@kernel.org>
> Cc: cgroups@vger.kernel.org
> Cc: linux-mm@kvack.org
> Cc: linux-kernel@vger.kernel.org
> ---
>   mm/memcontrol.c | 12 +++++-------
>   1 file changed, 5 insertions(+), 7 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index e8a1b0d95ba8..19fd911e8098 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2550,12 +2550,12 @@ static void cancel_charge(struct mem_cgroup *memcg, unsigned int nr_pages)
>   static void lock_page_lru(struct page *page, int *isolated)
>   {
>   	pg_data_t *pgdat = page_pgdat(page);
> +	struct lruvec *lruvec = mem_cgroup_page_lruvec(page, pgdat);
>   

What protects lruvec from freeing at this point?
After reading resolving lruvec page could be moved and cgroup deleted.

In this old patches I've used RCU for that: https://lkml.org/lkml/2012/2/20/276
Pointer to lruvec should be resolved under disabled irq.
Not sure this works these days.

> -	spin_lock_irq(&pgdat->lruvec.lru_lock);
> +	spin_lock_irq(&lruvec->lru_lock);
> +	sync_lruvec_pgdat(lruvec, pgdat);
>   	if (PageLRU(page)) {
> -		struct lruvec *lruvec;
>   
> -		lruvec = mem_cgroup_page_lruvec(page, pgdat);
>   		ClearPageLRU(page);
>   		del_page_from_lru_list(page, lruvec, page_lru(page));
>   		*isolated = 1;
> @@ -2566,16 +2566,14 @@ static void lock_page_lru(struct page *page, int *isolated)
>   static void unlock_page_lru(struct page *page, int isolated)
>   {
>   	pg_data_t *pgdat = page_pgdat(page);
> +	struct lruvec *lruvec = mem_cgroup_page_lruvec(page, pgdat);
>   
>   	if (isolated) {
> -		struct lruvec *lruvec;
> -
> -		lruvec = mem_cgroup_page_lruvec(page, pgdat);
>   		VM_BUG_ON_PAGE(PageLRU(page), page);
>   		SetPageLRU(page);
>   		add_page_to_lru_list(page, lruvec, page_lru(page));
>   	}
> -	spin_unlock_irq(&pgdat->lruvec.lru_lock);
> +	spin_unlock_irq(&lruvec->lru_lock);
>   }
>   
>   static void commit_charge(struct page *page, struct mem_cgroup *memcg,
> 


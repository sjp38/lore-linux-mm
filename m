Return-Path: <SRS0=On+J=TX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=FREEMAIL_FORGED_FROMDOMAIN,
	FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E7CA3C282DD
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 15:51:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 770FD2175B
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 15:51:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 770FD2175B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=sina.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D31C56B028C; Thu, 23 May 2019 11:51:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CE2896B028E; Thu, 23 May 2019 11:51:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BD1736B028F; Thu, 23 May 2019 11:51:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 86FD06B028C
	for <linux-mm@kvack.org>; Thu, 23 May 2019 11:51:40 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id b5so3733146plr.16
        for <linux-mm@kvack.org>; Thu, 23 May 2019 08:51:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=ZpdaRvVQoUYTGRs6h8yy747Yce8FHZuYtY5CtaPD6N8=;
        b=Qp72Xr4GVcfI0hd5QeGVm2BqfKDqBNB557cEz9F2vZkO5FVDTFyiV5BT0GaxMO/xw5
         fhc8uorm6cFD4xjXuH9+CdxROYP9iIVSaoRK+0cYo+ydeWiX/QKmWDi2gpRkeJ/tJj67
         O/7QhDX4GCgsqHkFZf/vD+g3NeDtvoSFPIwL+qVKlceIXodrrkHcEcHscVBa7/Tcz7eu
         Vt4MvT3R/ulWvsSHWuVlOQdHaySF4P7LbrlejQKKjnp0/XxIZ/RA1IwsC0S5WXqsiQmc
         jioMQmB5be76eA6JuKs7PWYr1XJHIKQWMQKi9FuJ6U3PBeUVpbuCLtR9Be4rOdU3tLEt
         jQkA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.3.164 as permitted sender) smtp.mailfrom=hdanton@sina.com
X-Gm-Message-State: APjAAAWPVeBwI/58syI5SUaDATis/Lx4x1zRBjvfRt2F0T9/aiXDXdbC
	/+Jh2WwbtuYzGsuuiP0ueP7f1CL4CjkdKjpBYXaktACkMfd1sslhGxW1GYzNYZSvPcfiM2Ph4Tq
	sxC2CccriyGzTqJjC9iM7QqyYnT2KqyzXAzWS5HMRwjHp9VBE2sBz4cIN10VKKBUyng==
X-Received: by 2002:a62:82c1:: with SMTP id w184mr74028245pfd.171.1558626700162;
        Thu, 23 May 2019 08:51:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyyqw7sj93XMEyqW+EOY7MJZYL21Wd4TamBBOoRU9vt05fULlRQA++rT3oHc62IAXf1PQAs
X-Received: by 2002:a62:82c1:: with SMTP id w184mr74028151pfd.171.1558626699327;
        Thu, 23 May 2019 08:51:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558626699; cv=none;
        d=google.com; s=arc-20160816;
        b=PQ1c5KhgrFZiucgso7cCZpMLPbxpXV6pgvGk07hVIxrJehoVMstpxDzN/TOhxIagTg
         c9RcV9aCp31GjdwQFD3ruHHp7crPtS695mIznx8cm+Kxz6lHa179hv8n514nEzSXhwXY
         dYelzNzoulco3mhs6IjLednirm6AUID5poiGiqItIpxoWifOI+wXTEKeagsaRDmA3xB+
         2ZHtxJo4tyuzK9GQL+Fg3z2VpUs3UQsDMAHk0B3u5ia34Re5Puh3wTsF6LrsMmwIExNj
         FhcifQbLhe28QTTZGGm1td/Ji4oTRiYupRBMbhx2/81QolbpLXezOdu+sbRhGl0FGRvt
         NqAg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=ZpdaRvVQoUYTGRs6h8yy747Yce8FHZuYtY5CtaPD6N8=;
        b=TKvtppgolOXOv3vfVdgF0cTMhMF5AC6HZCj9tFhyn3Na54nDrgiYfVtjV/dRWXwUV7
         NSMQ1XJf3sqLDb/ZVnMaejF0HIrdVwQnyMlDcxQ9rR1aLYityen0oi6OFCQ+7ozrs/l+
         u+P+cQCN6qfmXtb9Csyz5EZC5QdcL6ft0ORq5TX2+ctWedI5/H7oirchJW2BDSGfkOx2
         KglYzYr9jr3RWoXPVOZkVKJVW7lImg2lfmkjVdqe0S0tbEpKHkHLWbgSOtsZZdMmbag+
         /3FyBfyRc7gvZp4lbmJK/WcoUGCsoFEcWN8t+9QrpoZDEe/MqGV+9oLe5ZibTzWpyLwO
         riwg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.3.164 as permitted sender) smtp.mailfrom=hdanton@sina.com
Received: from mail3-164.sinamail.sina.com.cn (mail3-164.sinamail.sina.com.cn. [202.108.3.164])
        by mx.google.com with SMTP id d1si1132567pjv.85.2019.05.23.08.51.38
        for <linux-mm@kvack.org>;
        Thu, 23 May 2019 08:51:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of hdanton@sina.com designates 202.108.3.164 as permitted sender) client-ip=202.108.3.164;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.3.164 as permitted sender) smtp.mailfrom=hdanton@sina.com
Received: from unknown (HELO localhost.localdomain)([114.253.229.186])
	by sina.com with ESMTP
	id 5CE6C187000025A8; Thu, 23 May 2019 23:51:37 +0800 (CST)
X-Sender: hdanton@sina.com
X-Auth-ID: hdanton@sina.com
X-SMAIL-MID: 321269394360
From: Hillf Danton <hdanton@sina.com>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: ying.huang@intel.com,
	hannes@cmpxchg.org,
	mhocko@suse.com,
	mgorman@techsingularity.net,
	kirill.shutemov@linux.intel.com,
	josef@toxicpanda.com,
	hughd@google.com,
	shakeelb@google.com,
	akpm@linux-foundation.org,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [v4 PATCH 2/2] mm: vmscan: correct some vmscan counters for THP swapout
Date: Thu, 23 May 2019 23:51:26 +0800
Message-Id: <20190523155126.2312-1-hdanton@sina.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On Thu, 23 May 2019 10:27:38 +0800 Yang Shi wrote:
> 
> @ -1642,14 +1650,14 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
>  	unsigned long nr_zone_taken[MAX_NR_ZONES] = { 0 };
>  	unsigned long nr_skipped[MAX_NR_ZONES] = { 0, };
>  	unsigned long skipped = 0;
> -	unsigned long scan, total_scan, nr_pages;
> +	unsigned long scan, total_scan;
> +	unsigned long nr_pages;
Change for no earn:)

>  	LIST_HEAD(pages_skipped);
>  	isolate_mode_t mode = (sc->may_unmap ? 0 : ISOLATE_UNMAPPED);
>  
> +	total_scan = 0;
>  	scan = 0;
> -	for (total_scan = 0;
> -	     scan < nr_to_scan && nr_taken < nr_to_scan && !list_empty(src);
> -	     total_scan++) {
> +	while (scan < nr_to_scan && !list_empty(src)) {
>  		struct page *page;
AFAICS scan currently prevents us from looping for ever, while nr_taken bails
us out once we get what's expected, so I doubt it makes much sense to cut
nr_taken off.
>  
>  		page = lru_to_page(src);
> @@ -1657,9 +1665,12 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
>  
>  		VM_BUG_ON_PAGE(!PageLRU(page), page);
>  
> +		nr_pages = 1 << compound_order(page);
> +		total_scan += nr_pages;
> +
>  		if (page_zonenum(page) > sc->reclaim_idx) {
>  			list_move(&page->lru, &pages_skipped);
> -			nr_skipped[page_zonenum(page)]++;
> +			nr_skipped[page_zonenum(page)] += nr_pages;
>  			continue;
>  		}
>  
> @@ -1669,10 +1680,9 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
>  		 * ineligible pages.  This causes the VM to not reclaim any
>  		 * pages, triggering a premature OOM.
>  		 */
> -		scan++;
> +		scan += nr_pages;
The comment looks to defy the change if we fail to add a huge page to
the dst list; otherwise nr_taken knows how to do the right thing. What
I prefer is to let scan to do one thing a time.

>  		switch (__isolate_lru_page(page, mode)) {
>  		case 0:
> -			nr_pages = hpage_nr_pages(page);
>  			nr_taken += nr_pages;
>  			nr_zone_taken[page_zonenum(page)] += nr_pages;
>  			list_move(&page->lru, dst);
> -- 
> 1.8.3.1
> 
Best Regards
Hillf


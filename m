Return-Path: <SRS0=007R=T7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: *
X-Spam-Status: No, score=1.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5E832C46460
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 23:14:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 142C726FE4
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 23:14:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="TIt5gc6s"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 142C726FE4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9BB3A6B0269; Fri, 31 May 2019 19:14:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 992926B026A; Fri, 31 May 2019 19:14:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 881866B026B; Fri, 31 May 2019 19:14:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 518326B0269
	for <linux-mm@kvack.org>; Fri, 31 May 2019 19:14:49 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id 91so7306082pla.7
        for <linux-mm@kvack.org>; Fri, 31 May 2019 16:14:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=sqg+k083UjuBaC9GIrtmvRgUBVLo9R/vwLVNgUStm7o=;
        b=oBV+HvAy29+pkYSX0/EKKMYFokW3tDynwJMjQZ0pDn7deCawOrG5IjRHWdgML0aFJQ
         ogVF5JumxqEiQdiDBHqPomaMOtyMyE9nLD75/8g5GxnsEF39RfmkEuClCsWdIaZnrZIO
         cT8f7nxpkAQYvhvZ3XkVNekWYoe9Lse42aNNdTMewFv1Eo3pgfnqD1I9esMa5VX9w1f+
         R7Vs7fabFYo36ot7KyJOMhylw4vr95/HciCYxnaC7R9TY9P3iIT5eEVLgmYxGBsCCTrI
         FTpkLcDDxnEzR43uLh1wqN76u7X0eIBDORce6H0YoA95zUGe+RMm2ZdACL+59w0uR8GK
         b26Q==
X-Gm-Message-State: APjAAAWV1uu2Zy7LzX40LxlqxgK+RKCigKdrQ7s7hjMjydVep4ArAQLY
	ZDm9cxGD5DkjZ7gHluXEWEFRKklo3G0V73Wn6Hym541eyR5kLak4eI4611Rj+DDAuzw7ZoCWK0P
	VSX6pq+TU8ec0qfMD9mGWa10RIaOo+kofkVavTydZa9SAtqBAmO9GomG5SAcytsU=
X-Received: by 2002:a65:62c6:: with SMTP id m6mr12263036pgv.306.1559344488799;
        Fri, 31 May 2019 16:14:48 -0700 (PDT)
X-Received: by 2002:a65:62c6:: with SMTP id m6mr12262989pgv.306.1559344487864;
        Fri, 31 May 2019 16:14:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559344487; cv=none;
        d=google.com; s=arc-20160816;
        b=PAEF1ZlcDL49pgozGKxIQGzN6kaqGgFybmlxWzj8RG/Z9VAl6yX916eRSZn2gLHAnf
         hNicf4pLI5rd9xIrrntbCkCZnyF2hRHj/XJFBc0XYEaGK5Q+TErfBjlujJDtzmkIwKwg
         8QJzdLY1IONPvc1mPxxxk8ZEUhGqBGH61h5AXHcIiH+KVWcbkxcEdtX6Kldk8M2kNzbD
         DnlvakXy+QSV/PHRYIPFBYNoPrAoLudn1YAZ6zQQGACpcSBBmUeyz5lVbd+c32ER+pXi
         z42bWFd/gpxSjzUkizuSRNrB7npM5b3Id7glnAtIpv6RgmzNpcfPbS3jiENiGvBhU6KM
         n5Xg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=sqg+k083UjuBaC9GIrtmvRgUBVLo9R/vwLVNgUStm7o=;
        b=qlxx/OozjVugsk4eo85cFqj3L9LOq83WIvttUuOLjCXZs3et92NL0qPC1PCbyrTPai
         au90bygUpTrwI3t+/qLu61Y7uSHdCnWv/nMM4J2itJW7r/WyXMf45L0uTGN21xgH1a57
         j78DJ3Avu/r7f3sCqqFLjliWSM4EhO/aa6vJPrsWH97lJcdM+Jhc0pv71ckks+9ky8iR
         KH9Z3leO6hn3sSJoHF1+sLHg1/xbZNN0po7bURTSm1fszoxxQy9+I/2M9SokcRvpeRsw
         UhzYOJSwx6dVOWkDQHvUxwJPV1B//F0G7Vg793KELjDrgxjUZsnyUidLUinZdLhFxUG9
         PXbQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=TIt5gc6s;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c22sor2300148pgi.11.2019.05.31.16.14.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 31 May 2019 16:14:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=TIt5gc6s;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=sqg+k083UjuBaC9GIrtmvRgUBVLo9R/vwLVNgUStm7o=;
        b=TIt5gc6sWWBRszHh4EYFe1xGzN/GdjxvaWM8K2lb6Xim/4FxDuLYAD1Ln2BwGq45N+
         //hSJoE0haJkdEoYT574H8cfE9MQgXFzRw9sOmwzIyx/aypjCsv4NovefY7K4x0WskEI
         IVectjaxNeGeZFgbtOeR9p5BUkF0lD48nEbVmxysSoLNH++JgwHrLIIZUaAC+hoCL9rz
         n1qDpabUzsB7ye5w7gl61SKBt5e5S2OL0wW9YBBdj8rdOiA82r+94WHIIEKuKl0Y2sDz
         QaC76D/Cz/zHvImRoMHQofTytuSRimSdWNmb8t32cHGYtCcoWqLEK3GnHTXJbc6FyvpX
         Ywog==
X-Google-Smtp-Source: APXvYqxX11lcuUNZhgtux5VQO7zQRp/yiNhP/Uuovf9qi9asywvg1BHUnB4cqyA87l6NJmsdUFW+ew==
X-Received: by 2002:a63:c203:: with SMTP id b3mr11763122pgd.398.1559344487353;
        Fri, 31 May 2019 16:14:47 -0700 (PDT)
Received: from google.com ([122.38.223.241])
        by smtp.gmail.com with ESMTPSA id j7sm1044314pgp.88.2019.05.31.16.14.40
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 31 May 2019 16:14:46 -0700 (PDT)
Date: Sat, 1 Jun 2019 08:14:38 +0900
From: Minchan Kim <minchan@kernel.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>,
	linux-api@vger.kernel.org, Michal Hocko <mhocko@suse.com>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	Brian Geffon <bgeffon@google.com>, jannh@google.com,
	oleg@redhat.com, christian@brauner.io, oleksandr@redhat.com,
	hdanton@sina.com
Subject: Re: [RFCv2 3/6] mm: introduce MADV_PAGEOUT
Message-ID: <20190531231438.GA248371@google.com>
References: <20190531064313.193437-1-minchan@kernel.org>
 <20190531064313.193437-4-minchan@kernel.org>
 <20190531165927.GA20067@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190531165927.GA20067@cmpxchg.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hey Johannes,

On Fri, May 31, 2019 at 12:59:27PM -0400, Johannes Weiner wrote:
> Hi Michan,
> 
> this looks pretty straight-forward to me, only one kink:
> 
> On Fri, May 31, 2019 at 03:43:10PM +0900, Minchan Kim wrote:
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -2126,6 +2126,83 @@ static void shrink_active_list(unsigned long nr_to_scan,
> >  			nr_deactivate, nr_rotated, sc->priority, file);
> >  }
> >  
> > +unsigned long reclaim_pages(struct list_head *page_list)
> > +{
> > +	int nid = -1;
> > +	unsigned long nr_isolated[2] = {0, };
> > +	unsigned long nr_reclaimed = 0;
> > +	LIST_HEAD(node_page_list);
> > +	struct reclaim_stat dummy_stat;
> > +	struct scan_control sc = {
> > +		.gfp_mask = GFP_KERNEL,
> > +		.priority = DEF_PRIORITY,
> > +		.may_writepage = 1,
> > +		.may_unmap = 1,
> > +		.may_swap = 1,
> > +	};
> > +
> > +	while (!list_empty(page_list)) {
> > +		struct page *page;
> > +
> > +		page = lru_to_page(page_list);
> > +		if (nid == -1) {
> > +			nid = page_to_nid(page);
> > +			INIT_LIST_HEAD(&node_page_list);
> > +			nr_isolated[0] = nr_isolated[1] = 0;
> > +		}
> > +
> > +		if (nid == page_to_nid(page)) {
> > +			list_move(&page->lru, &node_page_list);
> > +			nr_isolated[!!page_is_file_cache(page)] +=
> > +						hpage_nr_pages(page);
> > +			continue;
> > +		}
> > +
> > +		mod_node_page_state(NODE_DATA(nid), NR_ISOLATED_ANON,
> > +					nr_isolated[0]);
> > +		mod_node_page_state(NODE_DATA(nid), NR_ISOLATED_FILE,
> > +					nr_isolated[1]);
> > +		nr_reclaimed += shrink_page_list(&node_page_list,
> > +				NODE_DATA(nid), &sc, TTU_IGNORE_ACCESS,
> > +				&dummy_stat, true);
> > +		while (!list_empty(&node_page_list)) {
> > +			struct page *page = lru_to_page(&node_page_list);
> > +
> > +			list_del(&page->lru);
> > +			putback_lru_page(page);
> > +		}
> > +		mod_node_page_state(NODE_DATA(nid), NR_ISOLATED_ANON,
> > +					-nr_isolated[0]);
> > +		mod_node_page_state(NODE_DATA(nid), NR_ISOLATED_FILE,
> > +					-nr_isolated[1]);
> > +		nid = -1;
> > +	}
> > +
> > +	if (!list_empty(&node_page_list)) {
> > +		mod_node_page_state(NODE_DATA(nid), NR_ISOLATED_ANON,
> > +					nr_isolated[0]);
> > +		mod_node_page_state(NODE_DATA(nid), NR_ISOLATED_FILE,
> > +					nr_isolated[1]);
> > +		nr_reclaimed += shrink_page_list(&node_page_list,
> > +				NODE_DATA(nid), &sc, TTU_IGNORE_ACCESS,
> > +				&dummy_stat, true);
> > +		mod_node_page_state(NODE_DATA(nid), NR_ISOLATED_ANON,
> > +					-nr_isolated[0]);
> > +		mod_node_page_state(NODE_DATA(nid), NR_ISOLATED_FILE,
> > +					-nr_isolated[1]);
> > +
> > +		while (!list_empty(&node_page_list)) {
> > +			struct page *page = lru_to_page(&node_page_list);
> > +
> > +			list_del(&page->lru);
> > +			putback_lru_page(page);
> > +		}
> > +
> > +	}
> 
> The NR_ISOLATED accounting, nid parsing etc. is really awkward and
> makes it hard to see what the function actually does.
> 
> Can you please make those ISOLATED counters part of the isolation API?
> Your patch really shows this is an overdue cleanup.

Yeah, that was very painful.

> 
> These are fast local percpu counters, we don't need the sprawling
> batching we do all over vmscan.c, migrate.c, khugepaged.c,
> compaction.c etc. Isolation can increase the counter page by page, and
> reclaim or putback can likewise decrease them one by one.
> 
> It looks like mlock is the only user of the isolation api that does
> not participate in the NR_ISOLATED_* counters protocol, but I don't
> see why it wouldn't, or why doing so would hurt.
> 
> There are also seem to be quite a few callsites that use the atomic
> versions of the counter API when they're clearly under the irqsafe
> lru_lock. That would be fixed automatically by this work as well.

I agree all points so will prepare clean up patch.


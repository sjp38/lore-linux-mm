Return-Path: <SRS0=bABq=VI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.5 required=3.0 tests=FREEMAIL_FORGED_FROMDOMAIN,
	FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 670D8C74A35
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 15:45:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F316D2166E
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 15:45:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F316D2166E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=sina.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8D2EF8E00E8; Thu, 11 Jul 2019 11:45:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 85C638E00DB; Thu, 11 Jul 2019 11:45:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 723C18E00E8; Thu, 11 Jul 2019 11:45:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 356568E00DB
	for <linux-mm@kvack.org>; Thu, 11 Jul 2019 11:45:06 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id f18so3826035pgb.10
        for <linux-mm@kvack.org>; Thu, 11 Jul 2019 08:45:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:thread-topic
         :content-transfer-encoding;
        bh=DCfj602Q7m8eFdFJ94lh0ZXysQuyEM3EtMv0DYoCDGM=;
        b=QKp+wK4Tomq9Lwba0DOlYMDZDkXOfcgatz98vyOTrq0eJYZNSOfuhhdXut0rxCdk+q
         9qwwN1H2DpCK0ePKb1EpBM3i3BjX53obUEiHXqfnY29O2m/zkfKHfA6ZlvPgjIoVyYFy
         FuglFXuvC004t71HoYfSKdxdSV0Wi669mqGOGDZAB1QCLZrQ3lxwlli+em3RCtafIByb
         f0z5AbZGUNa2M0KgH+HEwKeZB9wQsws6Z9yeLNSRVzVadgS/M/cHmhnmpWWMJMqc5Bkf
         f8xtxoKeab9mNwl51xV6Vg6k+g9b/lDvdXF1Lko76U7/ZUM0t2bhazXqGUOXwigtoJem
         fBdg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.3.167 as permitted sender) smtp.mailfrom=hdanton@sina.com
X-Gm-Message-State: APjAAAW6zKe3wzZ0eP3lMYqb/NA1riiFKe3xHVWTAZ5h63O80C+KI/3c
	S7PZzFnhBLdqSq9G+zc+c1VvkuxUWQ8mDQTS2067vOPtf204dc/2kBlc/PaRjhkt3RY9Mrt0b/G
	4Buuqlo5Yldk/vxD8cfw1dYZ9e6fkaU91AX7kauXup3zpqwHzqeb0pfCj5sBCBf4mSw==
X-Received: by 2002:a17:902:ba8b:: with SMTP id k11mr5375989pls.107.1562859905840;
        Thu, 11 Jul 2019 08:45:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqypD9WzTMjl7MgApk3jvQVQ0OsKZBPdJuXn722Ba6GjjIr7FxmBDwW3wL8rwF9keBH2n50+
X-Received: by 2002:a17:902:ba8b:: with SMTP id k11mr5375887pls.107.1562859904762;
        Thu, 11 Jul 2019 08:45:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562859904; cv=none;
        d=google.com; s=arc-20160816;
        b=q9NblEnJRfpyvjK2qyqQCHo6mdryBtGuSVSx5NUgYooOQG6r8AHdBAlKrIRUvTYaHy
         YJKqnyoeF5rm8W4n1cQLe8WK8uM9M7MI151CJtiySK9yF5VrM3SDvRXRZU5Ed9kX7jcp
         HDCTXidVwfKQ3HFxn64T3csjoc22CDMkkvvk8M6o9IpZwWnghFVK53T2is7yTfGNYaE1
         8Wa9brqZK1Ws/PYuw4YliaysbVtBpIpFow8YBbSF1ACCdUCZcEI+LIzpD3wZ/mwfelSE
         RLpZ/+Y4qmqwy8OG5AswAKNtSHR+QYLOoY67IKx8X3vgG6N7GEwHKS52DKczUCI8HdKY
         1TKg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:thread-topic:mime-version:message-id:date
         :subject:cc:to:from;
        bh=DCfj602Q7m8eFdFJ94lh0ZXysQuyEM3EtMv0DYoCDGM=;
        b=t1O1KkzrwdOvEshOOSdzMnJsyb8CQOgyujtzjsechd14kz/Cmse5z74fQPd2+sslCu
         IRonYpz5n4mhTsimF+tfHrML+6E9/ElpPmj11oj+D+JBYkaII3R2CNrJxwLdliGNG5aV
         XuXUgUaUoC87/P6GWiIKsl54D1zCqZ2ORbEJ7TOPOSdtOwCjQJwgNmEXHtk3qqkj7ARU
         kQhfg7x8wsjObD+hJeZKIMxnjV9ul6NKXPejE4ny04ZEHPk4jbzgaZq0SEY/vN5OvQUN
         NpIgOilptGTDhASYEmg2nIUJaF0+dDPFSbNOYgHPVoTXCBJBdeEPyzb20sKA6AtJPJ9W
         8PuQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.3.167 as permitted sender) smtp.mailfrom=hdanton@sina.com
Received: from mail3-167.sinamail.sina.com.cn (mail3-167.sinamail.sina.com.cn. [202.108.3.167])
        by mx.google.com with SMTP id 65si5455865ple.240.2019.07.11.08.45.04
        for <linux-mm@kvack.org>;
        Thu, 11 Jul 2019 08:45:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of hdanton@sina.com designates 202.108.3.167 as permitted sender) client-ip=202.108.3.167;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.3.167 as permitted sender) smtp.mailfrom=hdanton@sina.com
Received: from unknown (HELO localhost.localdomain)([221.219.5.31])
	by sina.com with ESMTP
	id 5D27597C000056EF; Thu, 11 Jul 2019 23:45:02 +0800 (CST)
X-Sender: hdanton@sina.com
X-Auth-ID: hdanton@sina.com
X-SMAIL-MID: 62729545088942
From: Hillf Danton <hdanton@sina.com>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Vlastimil Babka <vbabka@suse.cz>,
	Michal Hocko <mhocko@kernel.org>,
	Mel Gorman <mgorman@suse.de>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [Question] Should direct reclaim time be bounded?
Date: Thu, 11 Jul 2019 23:44:52 +0800
Message-Id: <20190711154452.4940-1-hdanton@sina.com>
MIME-Version: 1.0
Thread-Topic: Re: [Question] Should direct reclaim time be bounded?
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000002, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On Thu, 11 Jul 2019 02:42:56 +0800 Mike Kravetz wrote:
> On 7/7/19 10:19 PM, Hillf Danton wrote:
> > On Mon, 01 Jul 2019 20:15:51 -0700 Mike Kravetz wrote:
> >> On 7/1/19 1:59 AM, Mel Gorman wrote:
> >>>
> >>> I think it would be reasonable to have should_continue_reclaim allow an
> >>> exit if scanning at higher priority than DEF_PRIORITY - 2, nr_scanned is
> >>> less than SWAP_CLUSTER_MAX and no pages are being reclaimed.
> >>
> >> Thanks Mel,
> >>
> >> I added such a check to should_continue_reclaim.  However, it does not
> >> address the issue I am seeing.  In that do-while loop in shrink_node,
> >> the scan priority is not raised (priority--).  We can enter the loop
> >> with priority == DEF_PRIORITY and continue to loop for minutes as seen
> >> in my previous debug output.
> >>
> > Does it help raise prioity in your case?
> 
> Thanks Hillf,  sorry for delay in responding I have been AFK.
> 
> I am not sure if you wanted to try this somehow in addition to Mel's
> suggestion, or alone.
> 
I wanted you might take a look at it if you continued to have difficulty
raising scanning priority.

> Unfortunately, such a change actually causes worse behavior.
> 
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -2543,11 +2543,18 @@ static inline bool should_continue_reclaim(struct pglist_data *pgdat,
> >  	unsigned long pages_for_compaction;
> >  	unsigned long inactive_lru_pages;
> >  	int z;
> > +	bool costly_fg_reclaim = false;
> > 
> >  	/* If not in reclaim/compaction mode, stop */
> >  	if (!in_reclaim_compaction(sc))
> >  		return false;
> > 
> > +	/* Let compact determine what to do for high order allocators */
> > +	costly_fg_reclaim = sc->order > PAGE_ALLOC_COSTLY_ORDER &&
> > +				!current_is_kswapd();
> > +	if (costly_fg_reclaim)
> > +		goto check_compact;
> 
> This goto makes us skip the 'if (!nr_reclaimed && !nr_scanned)' test.
> 
Correct.

> > +
> >  	/* Consider stopping depending on scan and reclaim activity */
> >  	if (sc->gfp_mask & __GFP_RETRY_MAYFAIL) {
> >  		/*
> > @@ -2571,6 +2578,7 @@ static inline bool should_continue_reclaim(struct pglist_data *pgdat,
> >  			return false;
> >  	}
> > 
> > +check_compact:
> >  	/*
> >  	 * If we have not reclaimed enough pages for compaction and the
> >  	 * inactive lists are large enough, continue reclaiming
> 
> It is quite easy to hit the condition where:
> nr_reclaimed == 0  && nr_scanned == 0 is true, but we skip the previous test
> 
Erm it is becoming harder to imagine what prevented you from raising priority
when it was not difficult to hit the true condition above.

And I see the following in the mail thread,
===
	Date: Fri, 28 Jun 2019 11:20:42 -0700
	Message-ID: <dede2f84-90bf-347a-2a17-fb6b521bf573@oracle.com> (raw)
	In-Reply-To: <04329fea-cd34-4107-d1d4-b2098ebab0ec@suse.cz>

	I got back to looking into the direct reclaim/compaction stalls when
	trying to allocate huge pages.  As previously mentioned, the code is
	looping for a long time in shrink_node().  The routine
	should_continue_reclaim() returns true perhaps more often than it should.

	As Vlastmil guessed, my debug code output below shows nr_scanned is remaining
	non-zero for quite a while.  This was on v5.2-rc6.
===
nr_scanned != 0 and the result of should_continue_reclaim() is not false, which
is unable to match the condition you easily hit.


> and the compaction check:
> sc->nr_reclaimed < pages_for_compaction &&
> 	inactive_lru_pages > pages_for_compaction
> 
> is true, so we return true before the below check of costly_fg_reclaim
> 
It is the price high order allocations pay: reclaiming enough pages for
compact to do its work. With plenty of inactive pages you got no pages
reclaimed and scanned. It is really hard to imagine. And costly_fg_reclaim
is not good for that imho.

> > @@ -2583,6 +2591,9 @@ static inline bool should_continue_reclaim(struct pglist_data *pgdat,
> >  			inactive_lru_pages > pages_for_compaction)
> >  		return true;
> > 
> > +	if (costly_fg_reclaim)
> > +		return false;
> > +
> >  	/* If compaction would go ahead or the allocation would succeed, stop */
> >  	for (z = 0; z <= sc->reclaim_idx; z++) {
> >  		struct zone *zone = &pgdat->node_zones[z];
> > --
> >
> 
> As Michal suggested, I'm going to do some testing to see what impact
> dropping the __GFP_RETRY_MAYFAIL flag for these huge page allocations
> will have on the number of pages allocated.
> --
> Mike Kravetz
> 


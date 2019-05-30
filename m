Return-Path: <SRS0=aa49=T6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: *
X-Spam-Status: No, score=1.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CB45BC28CC0
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 00:45:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7CCEF243B0
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 00:45:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="b0rhC0Gn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7CCEF243B0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2A5CD6B0266; Wed, 29 May 2019 20:45:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 256096B026E; Wed, 29 May 2019 20:45:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 146DF6B026F; Wed, 29 May 2019 20:45:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id D4A1A6B0266
	for <linux-mm@kvack.org>; Wed, 29 May 2019 20:45:17 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id a5so2770001pla.3
        for <linux-mm@kvack.org>; Wed, 29 May 2019 17:45:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=3pQf3oE9pe7ut38GOYF86CTbPhCE2HZHC16fikq5yN4=;
        b=S+f5ockxbtrB2RnT9UVPz0D37OL17bZZ/p4qrteKEtDLi+sO1v0eORq/p3uRowg352
         S1wHHZ7qTOckm2t6Q7KbsiRg/P7gumQqnypWjV0O2p+VNfW3af4g6ZZzmP7gHY6/Vbjx
         q/hYV3KNfsj1zQIUY6z6xppt7F4kojmXK62Rw3Y1wg9Q+rufNuYol3/1yddUmOwfKQOK
         TJwWNhLvfNZHAupwi/Urxh4Xw3ECRsRvQccAlc8u1WtR5NsI7AZp5fHLV0ZlhcFejZUO
         KeELiMPfL3vJVgNzKBkAJRHjUEiKonOtDIPzp+JV7pogD3NyE5bGCPi+AIJVSiCgFEVD
         4cCg==
X-Gm-Message-State: APjAAAVoHy7KU8X/oal1sHkDiUINEK1BdsYhduBUWWR20zzP9+r+pHnT
	pG9dCyCvpp1EfEiPNGLBMwNLQvfIlhpuY4d5ZxjWWWiHICPlONg2v9rbsWR5qki8XP2Himhhlkv
	hGkICGqcTEdqFjfzWUX2tRbBz6ZA+jKbBdINIOAo8dSQdVg2ysstr9eGHN3oA4tg=
X-Received: by 2002:a63:6f0b:: with SMTP id k11mr934460pgc.342.1559177117474;
        Wed, 29 May 2019 17:45:17 -0700 (PDT)
X-Received: by 2002:a63:6f0b:: with SMTP id k11mr934325pgc.342.1559177115294;
        Wed, 29 May 2019 17:45:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559177115; cv=none;
        d=google.com; s=arc-20160816;
        b=n1Wm4+5Ot5wS6w9cNXlXl2xTSvXiowiPPTJ5+FQgwLPg0+o3g/vb1nkjtnTotkDqtz
         aW0dKCRFD1M3T2bL+KO3EVHvQcTWWdl4M+bi5koTcAQThK9WdR2hrYGTdBh0+QcSVHTC
         ycyv5skV/gO2Z9nRcnrbGP5scdJU5VGeWSXAXnWNLguSXHOwKAYwiy96NL+ifhoopugt
         9CqyssFiiOqwkVduXF7qgrZda80REcxbFxdQ7GqPfN0DADobrP88OX0hNFfAsVVywnRR
         WPICzfofpVQFx/xDHyE4HUGw5SmxebbUyUcfBORlVIhDv1rZxtANxa2TwLj8MhaY4Egz
         DsNw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=3pQf3oE9pe7ut38GOYF86CTbPhCE2HZHC16fikq5yN4=;
        b=vSlvcRuUtWIyWirAXrt1HCwLdHn/cEKLdBvfu44DzSBMBeHGaACubYNytmdC3yA322
         gy3ZFB2pONv2VYZHfxl4oTQG9eaq/eOIvJE8g0L/3tItCyoQJ7s9DfFwxQ2RmLTDMY71
         0xm/KxuJ+YQc1//+A/FSqQZx2r1zvtbWUfMVCuln+IpFHL4GT+gu8ts2kLdz7elA6k/r
         LC1+egpTld3OqKDTFDWKMMaIUgrSmRMoOszW0O5XuoFEj7NX8CirT4BgNemQNy/KTHib
         pj1LQB9g+ZLfFexGxy8e4Zm4tjhv5Lgez8pLchAJj21i3JLA7d1CK8A8BYMiD+ickEAe
         oA5A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=b0rhC0Gn;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p65sor1410462pfg.64.2019.05.29.17.45.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 29 May 2019 17:45:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=b0rhC0Gn;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=3pQf3oE9pe7ut38GOYF86CTbPhCE2HZHC16fikq5yN4=;
        b=b0rhC0GnaksDvk0NWeuH1qv7fPieZq9dXKXYRobup/o0JNscbNlpDJOYzfHN03PATj
         OHKJ0xZuwZZH2F+3URlVPUKBZOH+aTinvwRWog8zP7uTflJ6QdFQVbpKZHqJfi1IFeu8
         khW1oqaMCyj+NK+HU/0/smU4pi1IZ9amJI+fxmBOHfWKxlazKHZ5PHpryv2cISCV2/V+
         zyO0l1aRDazryxC70o7JgzWp7qZksuVAyeUdewD0qiRIoEziuBzQVolw7TXKpLD6KXOs
         ORsa6C3gaQ3krpOaXj9O7Hra3MD77Z6IQCs/0/7PLPI6MquEgy5BPIGmI658rVdhHTv1
         Pplw==
X-Google-Smtp-Source: APXvYqwt7gk7vehNu9cqSQXx8VB/7JE6vGRiMLtFRxLfQ3oXlqzDjKH+/HuhFg127Ccfn86BHVjTDw==
X-Received: by 2002:a63:f509:: with SMTP id w9mr978848pgh.134.1559177114886;
        Wed, 29 May 2019 17:45:14 -0700 (PDT)
Received: from google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id t5sm476354pgh.46.2019.05.29.17.45.10
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 29 May 2019 17:45:13 -0700 (PDT)
Date: Thu, 30 May 2019 09:45:07 +0900
From: Minchan Kim <minchan@kernel.org>
To: Hillf Danton <hdanton@sina.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	Michal Hocko <mhocko@suse.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	Brian Geffon <bgeffon@google.com>
Subject: Re: [RFC 3/7] mm: introduce MADV_COLD
Message-ID: <20190530004507.GC229459@google.com>
References: <20190520035254.57579-1-minchan@kernel.org>
 <20190520035254.57579-4-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190520035254.57579-4-minchan@kernel.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 28, 2019 at 10:54:32PM +0800, Hillf Danton wrote:
> 
> On Mon, 20 May 2019 12:52:50 +0900 Minchan Kim wrote:
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
> > +		list_del(&page->lru);
> > +
> > +		if (nid == -1) {
> > +			nid = page_to_nid(page);
> > +			INIT_LIST_HEAD(&node_page_list);
> > +			nr_isolated[0] = nr_isolated[1] = 0;
> > +		}
> > +
> > +		if (nid == page_to_nid(page)) {
> > +			list_add(&page->lru, &node_page_list);
> > +			nr_isolated[!!page_is_file_cache(page)] +=
> > +						hpage_nr_pages(page);
> > +			continue;
> > +		}
> > +
> Now, page's node != nid and any page on the node_page_list has
> node == nid. 
> > +		nid = page_to_nid(page);
> 
> After updating nid, we get the node id of the isolated pages lost.
> 
> > +
> > +		mod_node_page_state(NODE_DATA(nid), NR_ISOLATED_ANON,
> > +					nr_isolated[0]);
> > +		mod_node_page_state(NODE_DATA(nid), NR_ISOLATED_FILE,
> > +					nr_isolated[1]);
> > +		nr_reclaimed += shrink_page_list(&node_page_list,
> > +				NODE_DATA(nid), &sc, TTU_IGNORE_ACCESS,
> 
> And nid no longer matches the node of the pages to be shrunk.
> 
> > +				&dummy_stat, true);
> > +		while (!list_empty(&node_page_list)) {
> > +			struct page *page = lru_to_page(page_list);
> 
> Non-empty node_page_list will never become empty if pages are deleted
> only from the page_list.

Sure.
They were last minute change. I will fix it.

Thanks for the review!


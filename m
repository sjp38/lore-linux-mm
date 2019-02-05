Return-Path: <SRS0=TNGr=QM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 36848C282CB
	for <linux-mm@archiver.kernel.org>; Tue,  5 Feb 2019 11:21:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D470D2070B
	for <linux-mm@archiver.kernel.org>; Tue,  5 Feb 2019 11:21:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D470D2070B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 44BBA8E007F; Tue,  5 Feb 2019 06:21:17 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3FB088E001C; Tue,  5 Feb 2019 06:21:17 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2C6B38E007F; Tue,  5 Feb 2019 06:21:17 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id C29668E001C
	for <linux-mm@kvack.org>; Tue,  5 Feb 2019 06:21:16 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id c18so1189499edt.23
        for <linux-mm@kvack.org>; Tue, 05 Feb 2019 03:21:16 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=ocZ7InOwkicrryDy8zc2CWRAlvqRKcCK1AbyIp7nKVI=;
        b=tXVWeTSLwW23p92kNOrrfSSPQ32RFBf1SppuSYICzQMvzBwrtFHYYf1CDJ1E7lMTrW
         znfc64//0fHxpW2I0j8WW4oboyhCIkrfyPyi3MiLZ3/JReHWFmBFbH6NBY41QuXuyKfW
         i5wAQgvs1nh0H5rjuFOeVI0qht9P2Zme4y1iGwuaKJ3kk1whxttTCxc2Xngjalt+LQl4
         dkthpmwFvs0Bv6lM/xn5CXLMKhmXVR808J+KmylKLjTJ7EI7jSWHIs86Bf4nMKeQGoGy
         HaWoxs4ptggjiXJSms2NoulAj7mPz4Byy8gM1E6aOWFEK0zoSENwOmTWKt6W3FGr4YL1
         Fp3A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Gm-Message-State: AHQUAubiGVhv36L34Gisgf9FfQwJcw1IdQN49WLNdZnJ/52RiSRTNMYx
	YKMgQD1uSEJwV02XmBjks2O10ZAg4jNKCxwAw6jsJQz2TyssAT6j2Z7c0QAH1x0/yXLvxYM9tQX
	BUBJtBPtquWmmGkXesTfirQlwxwR2ri4hkViMU5XuLvICgCA9IxTL+dOXwrzWDTsBXA==
X-Received: by 2002:a17:906:470d:: with SMTP id y13mr3098762ejq.232.1549365676149;
        Tue, 05 Feb 2019 03:21:16 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbMKKS4zZ6ggzvT1nLeEoHaqr6QxFfxil/PsLHxaYD65UP4MJSObbKAG/D81PjAcKxUbw9u
X-Received: by 2002:a17:906:470d:: with SMTP id y13mr3098692ejq.232.1549365674988;
        Tue, 05 Feb 2019 03:21:14 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549365674; cv=none;
        d=google.com; s=arc-20160816;
        b=QbLWoVtUFNaUMyAV2bvrhYadcj4PATQfrXRlLeZyUZ5z7ATTqEAipqgihirOV74ONY
         qi5roHqYDveOQvcs6DzZIcjpQoZ8njl4AOAidh4QPFSJkxPjn9qWk8uyKrDBae0hoeEo
         2WYzGfxKNV1smV1gw1RE8JVP9RzVnbW9ItFvEOK3w2lbCk1LnSHyKyI4YTg0lzacpGrZ
         DjaCa6ywAublVG1uOjByZCp58r+vxvdtzQOCWxCmV4pSBt5PAaqsi2moYoK/bovBsHVW
         Jy1PLdCx2ZVKGE67/wkvROp1hct5XlXcnRCMu32WVz1g1OS8OJbKGrGm+vRRjZbkDWDF
         b+og==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=ocZ7InOwkicrryDy8zc2CWRAlvqRKcCK1AbyIp7nKVI=;
        b=XWYvL0QnV9I/WuXmT+HeY7cs+Ey2afwPUz/SyymUgoIQRM/nLXSWYJH1346Hf0Zl7G
         Bk+6VdbHd4UIKAdhCI0N7kFkIAl4yhkNnhs4/d6pHzEInm+Pjb7CIZWedyirnJgkPqOV
         /mfQroCI24dSFej83EBvjLlLBIyGYMUFP3/ja6P7zLMfRNDWtGbsIDTcTrVCUdfG06kY
         B12X9Bp0moim2vLTzVSE00UmpH3T9DkgXmYQXzgBBsHh0bPtzGC8RXG2fSVL3I8niOpO
         zsIEEDLfAxnpW2flYz6LPgz5VfjXVNCRDTfvGRBI64lb3lWG9CgBFJoadqmyb8aIPeH0
         wQPw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p18si120144edm.316.2019.02.05.03.21.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Feb 2019 03:21:14 -0800 (PST)
Received-SPF: pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 2D58BAA5C;
	Tue,  5 Feb 2019 11:21:14 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id 2DC0E1E3FED; Tue,  5 Feb 2019 12:21:07 +0100 (CET)
Date: Tue, 5 Feb 2019 12:21:07 +0100
From: Jan Kara <jack@suse.cz>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Jan Kara <jack@suse.cz>, lsf-pc@lists.linux-foundation.org,
	linux-fsdevel@vger.kernel.org, linux-mm@kvack.org,
	Dan Williams <dan.j.williams@intel.com>,
	Jerome Glisse <jglisse@redhat.com>
Subject: Re: [LSF/MM TOPIC] get_user_pages() pins in file mappings
Message-ID: <20190205112107.GB3872@quack2.suse.cz>
References: <20190124090400.GE12184@quack2.suse.cz>
 <a0d37cc9-2d44-ac58-0dc0-c245a55082c3@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a0d37cc9-2d44-ac58-0dc0-c245a55082c3@nvidia.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi John,

On Mon 04-02-19 15:46:10, John Hubbard wrote:
> On 1/24/19 1:04 AM, Jan Kara wrote:
> 
> > In particular we hope to have reasonably robust mechanism of identifying
> > pages pinned by GUP (patches will be posted soon) - I'd like to run that by
> > MM folks (unless discussion happens on mailing lists before LSF/MM). We
> > also have ideas how filesystems should react to pinned page in their
> > writepages methods - there will be some changes needed in some filesystems
> > to bounce the page if they need stable page contents. So I'd like to
> > explain why we chose to do bouncing to fs people (i.e., why we cannot just
> > wait, skip the page, do something else etc.) to save us from the same
> > discussion with each fs separately and also hash out what the API for
> > filesystems to do this should look like. Finally we plan to keep pinned
> > page permanently dirty - again something I'd like to explain why we do this
> > and gather input from other people.
> 
> Hi Jan,
> 
> Say, I was just talking through this point with someone on our driver team, 
> and suddenly realized that I'm now slightly confused on one point. If we end
> up keeping the gup-pinned pages effectively permanently dirty while pinned,
> then maybe the call sites no longer need to specify "dirty" (or not) when
> they call put_user_page*()?
> 
> In other words, the RFC [1] has this API:
> 
>     void put_user_page(struct page *page);
>     void put_user_pages_dirty(struct page **pages, unsigned long npages);
>     void put_user_pages_dirty_lock(struct page **pages, unsigned long npages);
>     void put_user_pages(struct page **pages, unsigned long npages);
> 
> But maybe we only really need this:
> 
>     void put_user_page(struct page *page);
>     void put_user_pages(struct page **pages, unsigned long npages);
> 
> ?
> 
> [1] https://lkml.kernel.org/r/20190204052135.25784-1-jhubbard@nvidia.com

So you are right that if we keep gup-pinned pages dirty, drivers could get
away without marking them as such. However I view "keep pages dirty" as an
implementation detail, rather than a promise of the API. So I'd like to
leave us the flexibility of choosing a different implementation in the
future. And as such I'd just leave the put_user_pages_dirty() variants in
place.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR


Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CB890C169C4
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 08:58:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A11172184D
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 08:58:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A11172184D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 30FB68E0002; Thu, 31 Jan 2019 03:58:13 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2BEA78E0001; Thu, 31 Jan 2019 03:58:13 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1D4CD8E0002; Thu, 31 Jan 2019 03:58:13 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id CC14D8E0001
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 03:58:12 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id p15so2027796pfk.7
        for <linux-mm@kvack.org>; Thu, 31 Jan 2019 00:58:12 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=MjwyhMyh0zvh7MFptK1UBupnU+juol4zGWhQN4zKer4=;
        b=Pj2S5uPPT9Z3qXta4NyCvGrQ0COJr8GexjF9GA/PPZrX2yHS+d366E9YIGS/5wa0NI
         61oqCbgYTCtB/thraQeRrCW2yvX1cenVKFNd1k3saq6+ruiIDmiYLBw0GlYAPu7vD//c
         6IScJWpNXBYkpyq9WmqxD5F085izyupN6fnauAc7G6UzQy+EKLYCiRU851vzbVMgFUl3
         0JXxW2r5R/G3kXuBRaUqEbUeDDQItuBqElHoWowqm22Di2f2X5+efN0fyUKO9t5WNzw9
         QIPoY8UMAzxrQ0GpU79c6s2Jn/WA/231rCZiZyrmAC0zS3OfLzTflljE9kC2eyFiciDu
         9zBA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AJcUukdjMjZs0I+fS/4uI34sbNFa3rc0fwWNxK4IfBbi1tDnpPAiQ7Nh
	TKeoxOLV1UHRKK0+7Bd23igoSy6ygMxhe15AxN3utjt3gVsFh6aeNQxL5NEuIxjSxpeehmE824Q
	C0cGSGH8vwcAfkrxuywPtfdbgk8K9K/q8fUKRbOQXuRkbUMjyesA4nWNwAaEcjao=
X-Received: by 2002:a17:902:a58c:: with SMTP id az12mr27420789plb.299.1548925092461;
        Thu, 31 Jan 2019 00:58:12 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4Pf0Q4gV66HGUbm0/uDF7sfMexQzsCGotKNrCPq2LRaeuikDCVQucR0HM277nLqTPB0qB/
X-Received: by 2002:a17:902:a58c:: with SMTP id az12mr27420749plb.299.1548925091575;
        Thu, 31 Jan 2019 00:58:11 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548925091; cv=none;
        d=google.com; s=arc-20160816;
        b=B2XCKhh3QNUAsbDSzKYAKHV+LrFznAcY2690Ht28fqpqLN3503sCbOyQfICSYVtgzb
         a+PkAeE0QYWrdR+NTe6RwW4M6GDWnzhYZ5U49T4SnTtprVrb7nF7RTc1LEKByvD4hsBc
         eHaqe7ReR5RRqL1rqtF9rzoOyp3bsA1g9njgEzMVcTAmiK9sGtNuWShmgJXtc4Ix22+6
         jN4qIvx+lLm0olYzUu2GxBCQgPv/E/xYYH7mWVA+Kf+PJ9GPpLoFYpBKwUjPymU9H2US
         neplOb4AyEE5zhkFV0bZ+JZy/1imniuVohkrVRoyltjaYCzANt0YqHht+I/B8IpUIMzE
         gqaA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=MjwyhMyh0zvh7MFptK1UBupnU+juol4zGWhQN4zKer4=;
        b=mWSRe2LcOJQso6gEe1t25Mkeg4FaoObHwjBsAOLpulEcbMd4EoclS+ZiHpGJExNRtn
         4otNL2oDwcUBbDVMApPKv5tj8feBQvJae18hFluvTHHRy0dT4+Ouc8L5DI04ctcHyVUX
         72lDPS1Hs3bqxKssDx+ubP4qdNZJ5bI64Vrd0kKEkcc9bWEzy+xlZ1aAoFLtw+KxgiCx
         r92pB1dBlLsxOToEPOn3Sq5WyI4YymSdyi8tsXNu+CbIRb464QuCsXpJ6YRFfAwLYXlr
         8GjpZIJoIJYj+MpfcQ1BXxUXmlH9zcysulqmVU+xQ+SeCe8DLivbimtjs4pCSkb1LdI9
         2BFw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k38si3645085pgi.235.2019.01.31.00.58.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Jan 2019 00:58:11 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id AFF46AD8A;
	Thu, 31 Jan 2019 08:58:09 +0000 (UTC)
Date: Thu, 31 Jan 2019 09:58:08 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Tejun Heo <tj@kernel.org>, Chris Down <chris@chrisdown.name>,
	Andrew Morton <akpm@linux-foundation.org>,
	Roman Gushchin <guro@fb.com>, Dennis Zhou <dennis@kernel.org>,
	linux-kernel@vger.kernel.org, cgroups@vger.kernel.org,
	linux-mm@kvack.org, kernel-team@fb.com
Subject: Re: [PATCH 2/2] mm: Consider subtrees in memory.events
Message-ID: <20190131085808.GO18811@dhcp22.suse.cz>
References: <20190124170117.GS4087@dhcp22.suse.cz>
 <20190124182328.GA10820@cmpxchg.org>
 <20190125074824.GD3560@dhcp22.suse.cz>
 <20190125165152.GK50184@devbig004.ftw2.facebook.com>
 <20190125173713.GD20411@dhcp22.suse.cz>
 <20190125182808.GL50184@devbig004.ftw2.facebook.com>
 <20190128125151.GI18811@dhcp22.suse.cz>
 <20190130192345.GA20957@cmpxchg.org>
 <20190130200559.GI18811@dhcp22.suse.cz>
 <20190130213131.GA13142@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190130213131.GA13142@cmpxchg.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 30-01-19 16:31:31, Johannes Weiner wrote:
> On Wed, Jan 30, 2019 at 09:05:59PM +0100, Michal Hocko wrote:
[...]
> > I thought I have already mentioned an example. Say you have an observer
> > on the top of a delegated cgroup hierarchy and you setup limits (e.g. hard
> > limit) on the root of it. If you get an OOM event then you know that the
> > whole hierarchy might be underprovisioned and perform some rebalancing.
> > Now you really do not care that somewhere down the delegated tree there
> > was an oom. Such a spurious event would just confuse the monitoring and
> > lead to wrong decisions.
> 
> You can construct a usecase like this, as per above with OOM, but it's
> incredibly unlikely for something like this to exist. There is plenty
> of evidence on adoption rate that supports this: we know where the big
> names in containerization are; we see the things we run into that have
> not been reported yet etc.
> 
> Compare this to real problems this has already caused for
> us. Multi-level control and monitoring is a fundamental concept of the
> cgroup design, so naturally our infrastructure doesn't monitor and log
> at the individual job level (too much data, and also kind of pointless
> when the jobs are identical) but at aggregate parental levels.
> 
> Because of this wart, we have missed problematic configurations when
> the low, high, max events were not propagated as expected (we log oom
> separately, so we still noticed those). Even once we knew about it, we
> had trouble tracking these configurations down for the same reason -
> the data isn't logged, and won't be logged, at this level.

Yes, I do understand that you might be interested in the hierarchical
accounting.

> Adding a separate, hierarchical file would solve this one particular
> problem for us, but it wouldn't fix this pitfall for all future users
> of cgroup2 (which by all available evidence is still most of them) and
> would be a wart on the interface that we'd carry forever.

I understand even this reasoning but if I have to chose between a risk
of user breakage that would require to reimplement the monitoring or an
API incosistency I vote for the first option. It is unfortunate but this
is the way we deal with APIs and compatibility.

> Adding a note in cgroup-v2.txt doesn't make up for the fact that this
> behavior flies in the face of basic UX concepts that underly the
> hierarchical monitoring and control idea of the cgroup2fs.
> 
> The fact that the current behavior MIGHT HAVE a valid application does
> not mean that THIS FILE should be providing it. It IS NOT an argument
> against this patch here, just an argument for a separate patch that
> adds this functionality in a way that is consistent with the rest of
> the interface (e.g. systematically adding .local files).
> 
> The current semantics have real costs to real users. You cannot
> dismiss them or handwave them away with a hypothetical regression.
> 
> I would really ask you to consider the real world usage and adoption
> data we have on cgroup2, rather than insist on a black and white
> answer to this situation.

Those users requiring the hierarchical beahvior can use the new file
without any risk of breakages so I really do not see why we should
undertake the risk and do it the other way around.
-- 
Michal Hocko
SUSE Labs


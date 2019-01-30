Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 064C7C282D7
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 20:06:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BE9A420989
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 20:06:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BE9A420989
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 640938E0004; Wed, 30 Jan 2019 15:06:03 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5EEE38E0001; Wed, 30 Jan 2019 15:06:03 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4B7868E0004; Wed, 30 Jan 2019 15:06:03 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id E3C8C8E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 15:06:02 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id d41so269228eda.12
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 12:06:02 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=C/o0gw9CWOCL0YUDcSVpAsEitM3Ombk0nlKLgUuvzls=;
        b=cAxg/VkoF+R/yrcGDE73HO6OBfg720GRcgqP07Rtx1HFyJAJoUgLWIknPOH/LoMs5o
         SaeL3oOu5XHRIvgm9CnlaTJRsd5VT6uEBGsfuD2f9Hj0ed1b+G2UysQ7oMJ6i8QJSlrv
         iWTXbrv1sjpLgtJRiGWK6MX/fHc0V4qTDdFUMPiumbTah5OYyV2cjBLXrNrXNUx740cA
         CzBDzC2PlY4FItvppSIjXOs87bNmVPt9TUQgPkVamnxC1h32pSCG3tWbA6ceqKFqAVeK
         uYQpCQIE1nzh6EC9h5eXDDDojgCdJWBaa6PSyrd4Ve1sJWhYyFUNHuilpe3YbgnGoMNf
         6AOQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AJcUukfag3OczHCDUPzU50l6gaBqjg5DuWY7SGr8D7aXT5afWHQk/T/j
	71PouARqVad2018cJN4JWE4jGDofQJgZbfMxcpKfslZVxfoOszRH+bdD1ToidNX936WIpTuB9Yj
	yLzGNs7i73dkQr7fU1QBxXuX21baR5zXR0i3sZMZHEzkgsSBMIB6eICLpVOgBDPY=
X-Received: by 2002:aa7:d8d3:: with SMTP id k19mr31327985eds.64.1548878762446;
        Wed, 30 Jan 2019 12:06:02 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5FHBZgm8wX64wfaqBwnjJVirYwt5gKlhCIPU5wPnz7q6G60/3KfxleWekIFNIBXsAc947v
X-Received: by 2002:aa7:d8d3:: with SMTP id k19mr31327926eds.64.1548878761357;
        Wed, 30 Jan 2019 12:06:01 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548878761; cv=none;
        d=google.com; s=arc-20160816;
        b=KmS7ZJ/EHfgQfe3+8QmASR53LUtVSX461EyLHUZc/5mMDPv9mRW7U3OfdEtZSsp0OS
         etGO6U6ecVau1QEmRHrctDv7beaYySG6XbI/jXCxdEXuBd91+3WUTQAB97BuW6Kr9Rln
         BhxtUgJQg2B9Gefy8Dlt9fOXytsmEETJ7qThxkY4iwn5hHem/717MpcQ7T08KHfO3TgT
         KdAga8pJTg2rq2YCmTM137KYJNQjzDB6ckPJjo2ibrTexxmYNfJgaAtROnR3+ewCA1qA
         vuzWO5e7UfzTtov58g8D4sZYPYI1CiyYQw+JkUHYAH/RzXLrg5Gx9tukh9zDho3RBAuC
         5uBg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=C/o0gw9CWOCL0YUDcSVpAsEitM3Ombk0nlKLgUuvzls=;
        b=jAYhIPbbxHbvLf3O8KT/Z1GqwR+qbDRVkR/RQ+MEspQQZlBdGob7i49vyOBnZ5RS1L
         uz5MHIra6Fi4LpyJD/gFd7caSpqFYRWuZF5jkUonYRYLmGwdLibvIUdeYplrygaFMGLH
         qI0BGLLaoc7JTuUStKtkUI7i7r17SEXZXS+gzJLcCoO0zzmPqtkx/pLUHP/5lOjM5Rnp
         xJ5o3hK9m3Y22R11xKChYuFEd8krxeYZMObjP0PSKcNREbd2gPtUvTXYP5BltKEuPKeE
         QUxxJOhBkqEBVy4oZuAA9Y41zmWokTxRVKg8j8sEF3ioFPV9FqNSSPT+74nztEWUXMi8
         YV3A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 7-v6si145272eji.75.2019.01.30.12.06.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Jan 2019 12:06:01 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 6C2FBAB87;
	Wed, 30 Jan 2019 20:06:00 +0000 (UTC)
Date: Wed, 30 Jan 2019 21:05:59 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Tejun Heo <tj@kernel.org>, Chris Down <chris@chrisdown.name>,
	Andrew Morton <akpm@linux-foundation.org>,
	Roman Gushchin <guro@fb.com>, Dennis Zhou <dennis@kernel.org>,
	linux-kernel@vger.kernel.org, cgroups@vger.kernel.org,
	linux-mm@kvack.org, kernel-team@fb.com
Subject: Re: [PATCH 2/2] mm: Consider subtrees in memory.events
Message-ID: <20190130200559.GI18811@dhcp22.suse.cz>
References: <20190124082252.GD4087@dhcp22.suse.cz>
 <20190124160009.GA12436@cmpxchg.org>
 <20190124170117.GS4087@dhcp22.suse.cz>
 <20190124182328.GA10820@cmpxchg.org>
 <20190125074824.GD3560@dhcp22.suse.cz>
 <20190125165152.GK50184@devbig004.ftw2.facebook.com>
 <20190125173713.GD20411@dhcp22.suse.cz>
 <20190125182808.GL50184@devbig004.ftw2.facebook.com>
 <20190128125151.GI18811@dhcp22.suse.cz>
 <20190130192345.GA20957@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190130192345.GA20957@cmpxchg.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 30-01-19 14:23:45, Johannes Weiner wrote:
> On Mon, Jan 28, 2019 at 01:51:51PM +0100, Michal Hocko wrote:
> > On Fri 25-01-19 10:28:08, Tejun Heo wrote:
> > > On Fri, Jan 25, 2019 at 06:37:13PM +0100, Michal Hocko wrote:
> > > > Please note that I understand that this might be confusing with the rest
> > > > of the cgroup APIs but considering that this is the first time somebody
> > > > is actually complaining and the interface is "production ready" for more
> > > > than three years I am not really sure the situation is all that bad.
> > > 
> > > cgroup2 uptake hasn't progressed that fast.  None of the major distros
> > > or container frameworks are currently shipping with it although many
> > > are evaluating switching.  I don't think I'm too mistaken in that we
> > > (FB) are at the bleeding edge in terms of adopting cgroup2 and its
> > > various new features and are hitting these corner cases and oversights
> > > in the process.  If there are noticeable breakages arising from this
> > > change, we sure can backpaddle but I think the better course of action
> > > is fixing them up while we can.
> > 
> > I do not really think you can go back. You cannot simply change semantic
> > back and forth because you just break new users.
> > 
> > Really, I do not see the semantic changing after more than 3 years of
> > production ready interface. If you really believe we need a hierarchical
> > notification mechanism for the reclaim activity then add a new one.
> 
> This discussion needs to be more nuanced.
> 
> We change interfaces and user-visible behavior all the time when we
> think nobody is likely to rely on it. Sometimes we change them after
> decades of established behavior - for example the recent OOM killer
> change to not kill children over parents.

That is an implementation detail of a kernel internal functionality.
Most of changes in the kernel tend to have user visible effects. This is
not what we are discussing here. We are talking about a change of user
visibile API semantic change. And that is a completely different story.

> The argument was made that it's very unlikely that we break any
> existing user setups relying specifically on this behavior we are
> trying to fix. I don't see a real dispute to this, other than a
> repetition of "we can't change it after three years".
> 
> I also don't see a concrete description of a plausible scenario that
> this change might break.
> 
> I would like to see a solid case for why this change is a notable risk
> to actual users (interface age is not a criterium for other changes)
> before discussing errata solutions.

I thought I have already mentioned an example. Say you have an observer
on the top of a delegated cgroup hierarchy and you setup limits (e.g. hard
limit) on the root of it. If you get an OOM event then you know that the
whole hierarchy might be underprovisioned and perform some rebalancing.
Now you really do not care that somewhere down the delegated tree there
was an oom. Such a spurious event would just confuse the monitoring and
lead to wrong decisions.
-- 
Michal Hocko
SUSE Labs


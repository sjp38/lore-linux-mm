Return-Path: <SRS0=h0DJ=VC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2458EC5B57D
	for <linux-mm@archiver.kernel.org>; Fri,  5 Jul 2019 23:53:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C95F320830
	for <linux-mm@archiver.kernel.org>; Fri,  5 Jul 2019 23:53:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C95F320830
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4C9926B0003; Fri,  5 Jul 2019 19:53:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 479AB8E0003; Fri,  5 Jul 2019 19:53:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 38FAF8E0001; Fri,  5 Jul 2019 19:53:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id F39D76B0003
	for <linux-mm@kvack.org>; Fri,  5 Jul 2019 19:53:34 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id h5so3114479pgq.23
        for <linux-mm@kvack.org>; Fri, 05 Jul 2019 16:53:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=0xKnFmVTZv3b5TBjj3WLSoEAYx0J4BQ9MYcIpS+T648=;
        b=uHsqxY8IUYvpEQ2cy51sO+Uq7aqwJYEeg+w6iWVuAg2tZix9Gmly74kZohybN33Xfa
         NoM7L07WgZbiZ1iuMfAJAWn1JLLC6niHUxu5zVl0ARr5vLXU2HeHzKHdMrA5hIeCxW9E
         iV99zsakrUtGnzecaQGySqGlipbn8gJSIoXqIo8HchzI4CBGOVIUuLitwL4ZNqAiDOl5
         sq/vVi0y02ZYKbAt4EKjpBilOC4N+PhVxgot8tc8Q7eJKtAUYDIcCecXpxr1EJIQjOR8
         uv7N4jnWOfFFdxe4pUnNka+jpasMaHDqJQXUCkZ6R9kuQQWPk45c6rQruCDtATEcQZQ+
         /g8Q==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
X-Gm-Message-State: APjAAAUJmZB2hcXzm22IyH2ELPmAnc/+yTBiyUbukmdPw5Yv2TYQnRQe
	hcezt5nP2bYbWvSo84CmRFO5D5z7bRo8O6bow3Bw/txgUxURzREdImuINq7YCmccL9xfyiv/6xZ
	hiPoO3NcvAQmzLPWThPjGf7cipfFxEiTo8FOOHlRhGgmC7Ba4zZCxnZ88Sdg+ksQ=
X-Received: by 2002:a63:5463:: with SMTP id e35mr8023696pgm.451.1562370814574;
        Fri, 05 Jul 2019 16:53:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyadsvuuNOWNLCB8TTBYmaEENSqBLHE/SNAaj69SauopwnBAISgbcgAbkbhGdO7R0s7Ft32
X-Received: by 2002:a63:5463:: with SMTP id e35mr8023654pgm.451.1562370813840;
        Fri, 05 Jul 2019 16:53:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562370813; cv=none;
        d=google.com; s=arc-20160816;
        b=XCQcexwxv6q2X6rPePRHmw2OtcndrXUBFWbL2THaxkqUD/gwc1BFzw3+X+XBmC5cUs
         hEUpF3pO2okWYuVYkqR+0KIBgUgLX5h3FML0IICeIsjUtHhkqlVzJOpgSnOFpnvK8Cvc
         pxY5HN4HXA4c9cYzW1EbAkoGn6emn1+PeFkfuB/eufCA8ph+cnL/sr6NUcS/Sy0Cb+Kf
         4/DwO+CzTWCftjG9ue0rOFJCCeZ/zhHDsnGdebXsRRUHGdq8P/VUWWg2rzeN19teMIL9
         D2suD7pin/3t0kM5kChKDeYgNyp1uPjkoUOECaf7ovV6/pS2a/1CJGdi+ourIecrptcX
         hyng==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=0xKnFmVTZv3b5TBjj3WLSoEAYx0J4BQ9MYcIpS+T648=;
        b=BImY0EwfkVI1jYYPSxpYzFALwNbe0zPJxYCrcUZJWwKlJclAW4miMJ0bEWsFBDEmpX
         xTrDlLhYmQJvk7HGPqkSvO9nfugACYYsYFan2wgcXrh1w5G4vuTWglDB4fRb4mjSSQF5
         ta20TQWsLfr4wvtxMdaWhnc1MS02zj+1W2kH4ve5VGHlRwPAstFS3WDhv5nGAvxk/qJX
         csAnxnkC6BKFHgoEXEhxf9IXXug7iolZMmLzug9pG7n0VoDOGXMcFZFAXiYPHl6gYAHt
         XBT2+9T+zjZqKRET5UfXueOr5uIitxrmz9R0hce145Z5rS4v/ISOHaj0QX4KvxFA4Wh1
         j3Yw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from mail105.syd.optusnet.com.au (mail105.syd.optusnet.com.au. [211.29.132.249])
        by mx.google.com with ESMTP id b2si8902333pgd.439.2019.07.05.16.53.33
        for <linux-mm@kvack.org>;
        Fri, 05 Jul 2019 16:53:33 -0700 (PDT)
Received-SPF: neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) client-ip=211.29.132.249;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from dread.disaster.area (pa49-195-139-63.pa.nsw.optusnet.com.au [49.195.139.63])
	by mail105.syd.optusnet.com.au (Postfix) with ESMTPS id 967F1149BDA;
	Sat,  6 Jul 2019 09:53:29 +1000 (AEST)
Received: from dave by dread.disaster.area with local (Exim 4.92)
	(envelope-from <david@fromorbit.com>)
	id 1hjY06-0005zx-1X; Sat, 06 Jul 2019 09:52:22 +1000
Date: Sat, 6 Jul 2019 09:52:22 +1000
From: Dave Chinner <david@fromorbit.com>
To: Brian Foster <bfoster@redhat.com>
Cc: Yafang Shao <laoar.shao@gmail.com>, Michal Hocko <mhocko@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux MM <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	Shakeel Butt <shakeelb@google.com>,
	Yafang Shao <shaoyafang@didiglobal.com>, linux-xfs@vger.kernel.org
Subject: Re: [PATCH] mm, memcg: support memory.{min, low} protection in
 cgroup v1
Message-ID: <20190705235222.GE7689@dread.disaster.area>
References: <1562310330-16074-1-git-send-email-laoar.shao@gmail.com>
 <20190705090902.GF8231@dhcp22.suse.cz>
 <CALOAHbAw5mmpYJb4KRahsjO-Jd0nx1CE+m0LOkciuL6eJtavzQ@mail.gmail.com>
 <20190705111043.GJ8231@dhcp22.suse.cz>
 <CALOAHbA3PL6-sBqdy-sGKC8J9QGe_vn4-QU8J1HG-Pgn60WFJA@mail.gmail.com>
 <20190705151045.GI37448@bfoster>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190705151045.GI37448@bfoster>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Optus-CM-Score: 0
X-Optus-CM-Analysis: v=2.2 cv=P6RKvmIu c=1 sm=1 tr=0 cx=a_idp_d
	a=fNT+DnnR6FjB+3sUuX8HHA==:117 a=fNT+DnnR6FjB+3sUuX8HHA==:17
	a=jpOVt7BSZ2e4Z31A5e1TngXxSK0=:19 a=kj9zAlcOel0A:10 a=0o9FgrsRnhwA:10
	a=VwQbUJbxAAAA:8 a=7-415B0cAAAA:8 a=ycwi4UZG3aNCvCUHsWIA:9
	a=CjuIK1q_8ugA:10 a=AjGcO6oz07-iQ99wixmX:22 a=biEYGPWJfzWAr4FL6Ov7:22
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jul 05, 2019 at 11:10:45AM -0400, Brian Foster wrote:
> cc linux-xfs
> 
> On Fri, Jul 05, 2019 at 10:33:04PM +0800, Yafang Shao wrote:
> > On Fri, Jul 5, 2019 at 7:10 PM Michal Hocko <mhocko@kernel.org> wrote:
> > >
> > > On Fri 05-07-19 17:41:44, Yafang Shao wrote:
> > > > On Fri, Jul 5, 2019 at 5:09 PM Michal Hocko <mhocko@kernel.org> wrote:
> > > [...]
> > > > > Why cannot you move over to v2 and have to stick with v1?
> > > > Because the interfaces between cgroup v1 and cgroup v2 are changed too
> > > > much, which is unacceptable by our customer.
> > >
> > > Could you be more specific about obstacles with respect to interfaces
> > > please?
> > >
> > 
> > Lots of applications will be changed.
> > Kubernetes, Docker and some other applications which are using cgroup v1,
> > that will be a trouble, because they are not maintained by us.
> > 
> > > > It may take long time to use cgroup v2 in production envrioment, per
> > > > my understanding.
> > > > BTW, the filesystem on our servers is XFS, but the cgroup  v2
> > > > writeback throttle is not supported on XFS by now, that is beyond my
> > > > comprehension.
> > >
> > > Are you sure? I would be surprised if v1 throttling would work while v2
> > > wouldn't. As far as I remember it is v2 writeback throttling which
> > > actually works. The only throttling we have for v1 is reclaim based one
> > > which is a huge hammer.
> > > --
> > 
> > We did it in cgroup v1 in our kernel.
> > But the upstream still don't support it in cgroup v2.
> > So my real question is why upstream can't support such an import file system ?
> > Do you know which companies  besides facebook are using cgroup v2  in
> > their product enviroment?
> > 
> 
> I think the original issue with regard to XFS cgroupv2 writeback
> throttling support was that at the time the XFS patch was proposed,
> there wasn't any test coverage to prove that the code worked (and the
> original author never followed up). That has since been resolved and
> Christoph has recently posted a new patch [1], which appears to have
> been accepted by the maintainer.

I don't think the validation issue has been resolved.

i.e. we still don't have regression tests that ensure it keeps
working it in future, or that it works correctly in any specific
distro setting/configuration. The lack of repeatable QoS validation
infrastructure was the reason I never merged support for this in the
first place.

So while the (simple) patch to support it has been merged now,
there's no guarantee that it will work as expected or continue to do
so over the long run as nobody upstream or in distro land has a way
of validating that it is working correctly.

From that perspective, it is still my opinion that one-off "works
for me" testing isn't sufficient validation for a QoS feature that
people will use to implement SLAs with $$$ penalities attached to
QoS failures....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com


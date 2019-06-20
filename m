Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: *
X-Spam-Status: No, score=1.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C6B4AC43613
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 08:44:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8ABE720657
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 08:44:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="aEzfvWfh"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8ABE720657
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 211406B0003; Thu, 20 Jun 2019 04:44:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1C1148E0002; Thu, 20 Jun 2019 04:44:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0897F8E0001; Thu, 20 Jun 2019 04:44:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id C62346B0003
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 04:44:15 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id h27so1530411pfq.17
        for <linux-mm@kvack.org>; Thu, 20 Jun 2019 01:44:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=sYUDpApbnrIBn4i7klGE9UQ92KtpIubNAiUNXQIv47k=;
        b=VXY3V38Zvs2Kfs/25Jw2eCartfdtx/8k9t2ObO2uKi+4KjbNW4+CA70SxhyZrquTbu
         XqhEQrrb+o4RvNThuFfhHZmLssEXPL10AAWTa+nijMifo9hYOexFYrTg9TXXXdTsAxFv
         zajct5IQQr6DLReATkanW5pvUkpg/eZh0OQHSWwLX5pXj6j5BI7NEOYd9QVETRA9JslA
         qzfAOSWxePH+Z5qGpNVP617euL6jMDkUWDQsSkwuF2xGaeT0MfvtlFvwCAF737qwUaA4
         hqln3jSmFQF9TU7h+dqwRLuPN4UxibFSaBrg4gOIDltyqelcgKsUNLEPb+EQ2QFF17yP
         fGEw==
X-Gm-Message-State: APjAAAV0O+XPCau8AG8YzPV10JEZqKDdetD/qyhuYRu8D0MFIkiV582G
	ur2aZ2iqm1w9A9vA3UnR/lqArLHZCroyJmH87GdvCwdKN2xyU2pc1OGOKsO/7qX6054aClYlmhj
	dezE6G6ueU9hx66BZ98TLBK3ht7WigSdJMxr5dRdrDMQzjfrLx9zI5ArJQq/r9RQ=
X-Received: by 2002:a65:484d:: with SMTP id i13mr11662733pgs.27.1561020255439;
        Thu, 20 Jun 2019 01:44:15 -0700 (PDT)
X-Received: by 2002:a65:484d:: with SMTP id i13mr11662702pgs.27.1561020254842;
        Thu, 20 Jun 2019 01:44:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561020254; cv=none;
        d=google.com; s=arc-20160816;
        b=PV5MoMW6LdJfGkcekRIuAdreMiJOiSEMvSOdCBvjbnDoSvFrbIX+vhFnBzWFJdYgCI
         FR/9z1pDX8UHdp+xDsvHoN9SQ/F3bpYnAqW7ib8g4jU22CDVo0IFQg/zMGAvH2+PUfbq
         eCrEl8WJ94S8AoYyE2i1xONXktd6WKjZapIm0Z9xYjCtJp7tSKXaMoJ1clekMLNdyM/R
         a1PjPa6lmvWLkeSiniY394a+asmERAJT+0K8V/S2YsObR7KXIyi5dpdBYQAnNJNqkShB
         IYR81bkeF5zY9d0ukoGsZbGL5uFuZETIiv63eOtaS0wOHD7mzgn73EII5vCuTaEVfCCp
         0FKw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=sYUDpApbnrIBn4i7klGE9UQ92KtpIubNAiUNXQIv47k=;
        b=rUQGJ+kOd1EHhrQJzDZqCrm8DYgl5xAXLFjHO3whankiWcMZ0dfNQrLhXsF+24cgXS
         O7UYjj33dSaqmbtfTIl6QlLV4Pr4Eamde/vQ89qpESZYjiaKQ51HYUrdLBTG7BzNkeuw
         bpyh6f/VqYuAvc298ff81TPFlHkWeYcsE97B8/H/IcG+HObtvDd/SOaL6lsGA16ubpzl
         f1m9gR/QxZGy24jwL7UrQ2VbFQqo4o+cK6y0AVtaNd1C11m5ssOxEXUeQVfIy/qQVrrr
         eNG/CbdvG39LcBOBcTxxJXAF2eZvDjW+YC6k/tIDhnFVUVTHbzC9I7T7fmzKo1tsSt+T
         1ymQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=aEzfvWfh;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d2sor23531591pln.13.2019.06.20.01.44.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 20 Jun 2019 01:44:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=aEzfvWfh;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=sYUDpApbnrIBn4i7klGE9UQ92KtpIubNAiUNXQIv47k=;
        b=aEzfvWfhJfjqwaVDjQ+y2Jj8uQ5QLxM1Z9rSTwdKEVkhpfKq1+Vqx4cQoEo3LUbewb
         nU43G4E5gYmlEqHnYPXnoi+dPlxxjyj2hEDeLmCouA0sk/KCNJqQM5lOtVQx7zd4IeOc
         Nu+R1IfH6LIZkVvQqJ0U2YjQ2u4vWRTNlgJkN4NcOLwYjLzEYcopTqj/2uLvHTnvSQPU
         G6VczY8GZn0HQXUzj2HmCQ64NCkoar+aFuvgFDt+OhG2jMZha7ZvtmNq0lzwD3a6508x
         bjre/yWIfx9smdOvOz6K9HtuVd9grJ7MlUsBVt5ku7kkUWkZ7zoHCriBmFVGGGAb2L31
         6iuw==
X-Google-Smtp-Source: APXvYqyNaeJOWDXCKLsONO3xoo0uW5BSwfxZeeqpUW3oEVsmOBAMneaKESWF6GWZ/kvgM7+JkXbHYQ==
X-Received: by 2002:a17:902:290b:: with SMTP id g11mr121725061plb.26.1561020254488;
        Thu, 20 Jun 2019 01:44:14 -0700 (PDT)
Received: from google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id q144sm28994756pfc.103.2019.06.20.01.44.08
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 20 Jun 2019 01:44:12 -0700 (PDT)
Date: Thu, 20 Jun 2019 17:44:06 +0900
From: Minchan Kim <minchan@kernel.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>,
	linux-api@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	Brian Geffon <bgeffon@google.com>, jannh@google.com,
	oleg@redhat.com, christian@brauner.io, oleksandr@redhat.com,
	hdanton@sina.com, lizeb@google.com
Subject: Re: [PATCH v2 1/5] mm: introduce MADV_COLD
Message-ID: <20190620084406.GE105727@google.com>
References: <20190610111252.239156-1-minchan@kernel.org>
 <20190610111252.239156-2-minchan@kernel.org>
 <20190619125611.GO2968@dhcp22.suse.cz>
 <20190620000650.GB52978@google.com>
 <20190620070854.GC12083@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190620070854.GC12083@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 20, 2019 at 09:08:54AM +0200, Michal Hocko wrote:
> On Thu 20-06-19 09:06:51, Minchan Kim wrote:
> > On Wed, Jun 19, 2019 at 02:56:12PM +0200, Michal Hocko wrote:
> [...]
> > > Why cannot we reuse a large part of that code and differ essentially on
> > > the reclaim target check and action? Have you considered to consolidate
> > > the code to share as much as possible? Maybe that is easier said than
> > > done because the devil is always in details...
> > 
> > Yub, it was not pretty when I tried. Please see last patch in this
> > patchset.
> 
> That is bad because this code is quite subtle - especially the THP part
> of it. I will be staring at the code some more. Maybe some
> simplification pops out.

Yeah, I couldn't come up with better idea. Actually, I wanted to be
left. More suggestion to make simple/readable would be great.


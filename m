Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D8348C282D7
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 19:30:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 93ED22087F
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 19:30:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="MBC71ieo"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 93ED22087F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2DA758E0015; Wed, 30 Jan 2019 14:30:30 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 287D68E0001; Wed, 30 Jan 2019 14:30:30 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 150808E0015; Wed, 30 Jan 2019 14:30:30 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id D62A98E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 14:30:29 -0500 (EST)
Received: by mail-yb1-f200.google.com with SMTP id e10so328696ybr.18
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 11:30:29 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=u4lGJa1eqm311IjOZIxyEEk5pH4RS2fwSIKRlT/c2bc=;
        b=aPd7Q+duCz4ga/aTySVv+lsYqpV8HkTIuph1VaJwSOyi+H/gneVx3CPAC6/F72lOq+
         bjW6ZdyhBG3ucxEuZJjwWfnkVPEMebRAipl0ms2RECmH+s2MuuFhV4XFJtXUfnwv0Zjv
         Xyma4xd7jbLAnj5I0aooSfYFohqpv21xJ2Dtr1388HYB4S3gRwjDGYhQfAanvAsIEFtV
         qlYIBEllSos+ScJ+2d5/CZkd+Wbux8cUzzXhh810dXSqyFJj49BIQGG79ppYWBXu+8BN
         jqFjRpX5VcIpmmMo7BPOXSNHwBDx4QkB3Bb5KU8T6wHiPATXNb2ZLbQ921ml+RAVZYj5
         D5/A==
X-Gm-Message-State: AHQUAuarELG4QnFH6WDxx08NBScTGxCr/RVgtyqpV4BaJxn5glksLYOM
	hWt1dOma5Wsco6g6TB5EFIZ5C5pEasuGTUdHU8cCNGg1mMLlegufGgY0iHPLZbxFPtvFdyudlF/
	0ZkSD6bocTaaQGX1ernydZxdx05YNXdW5knCVn5X+z7SjU+NJPdXP4l005aO/Y5hrYDB2M5ohWT
	EW4u/Gv5lB24Tz6ek5F4y7HFubODkjM7CCwjlcYMSWaF0748n0VB8ubEJCFzW79bWxk/eO04sGO
	MLOzU0yaLXo+ZWPgbOPcK7RqDVwZtDyJIlxZK/w2n5HX03YfHpNsO3l6g8Kra9ri44zThfLLW8u
	Kxqjw2awmJ3VmsnVEBI8J8zxrDnWfXEmouZrytP/5tJvtq0KLAY7EIkbzqM+JlTsdwthy3mVL7/
	J
X-Received: by 2002:a25:8482:: with SMTP id v2mr2752237ybk.500.1548876629578;
        Wed, 30 Jan 2019 11:30:29 -0800 (PST)
X-Received: by 2002:a25:8482:: with SMTP id v2mr2752208ybk.500.1548876629084;
        Wed, 30 Jan 2019 11:30:29 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548876629; cv=none;
        d=google.com; s=arc-20160816;
        b=zxRmxOzSNqmuBNkLd0+TtPfoLIJBH35L02Nc/bBAm0MCfk9yI0h3MOzSR1i3k8tm3l
         X1VwwbGdweLupa0z9C4o1VD7hHTmg7P1dilbK1mf621BdFBy9/rSJDQhNe1P88k4c9T3
         eESuGYkbTsJOg7WsIIjwrEUTouDdjYG5ndie2WDar+mUz6jfWKSPuqX7kkiFDIEM9osj
         MaNuWndnionda3AKbt9ravPWeLrOOdwx3a4VrBradAd0P3BvO4nmEPmT22mUeq5HbGLA
         QbhZEGqYFYvAkG6QIYKeiBOzpgHJya26tRVTvhMY6XndV4Gx1b/xTzf+WTlRrDeNZgFO
         YufA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=u4lGJa1eqm311IjOZIxyEEk5pH4RS2fwSIKRlT/c2bc=;
        b=RCPJ5nYhJQcTXKXEb/X6Z7Vs6+82yw5wGkncHg1lcj+C7RbVubXj9JwoD10cDv40TH
         hZF+AyOEXzUaihNBMYsvXv01DDPIKOBNLb5VvmlmlVkK+TJ1gqXo1JqFvZQzVVzJ0VXI
         k0Kvvcg6768xX2mAlGQfX/wr3j41VmtOkdniBnOiRpAoNmAPINCP0eM9cT3iJpOFFXSg
         vgcuoA4XJQTKk2Dnffw3qHcROrqfMB9f/HtITg1gKbTg+p7fr09LfiC6R1DiEdxyrS7H
         mLNc6TWrGTiAJHtdktmqSheseoiPSs5avSYDWgal/WHajIaTkeB2i2n46r4fhnCjgf62
         knNg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=MBC71ieo;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f5sor1086156yba.74.2019.01.30.11.30.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 30 Jan 2019 11:30:28 -0800 (PST)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=MBC71ieo;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=u4lGJa1eqm311IjOZIxyEEk5pH4RS2fwSIKRlT/c2bc=;
        b=MBC71ieoROyzpJYMm/RoM48yebOSHThzuo7d3oPiagXJfjLAD5AOCg12b0GXqJMHgo
         byQdg6fKygYXahH3gh70/beX8rcnd9A2w876UhzSUZRp1EC54kTTM02cUEIHzQF34GZP
         9/ViuRdoaByPgSw4yx6n4p8Dlns+T5Pw4L87bee6Hw8nuxjJXB+l8mHHb+lYM9bSEsYh
         p5FehOxBq3izQVdqa3zLxdA2sCUSafZvMUY7D91qtNGspuKGT1tm/XhwTSyKShEMwbNq
         n0dQ3h57xSEY0s45uLv7teLyVuciOaDK0y8LFHR9WeANLuoFKihiVwRYKw4TT3+TpzQm
         g2Mg==
X-Google-Smtp-Source: ALg8bN6aWM4PfrnEWZ0n7/syAfcjFDV7n2/VR+Rg6LPSuim4pyDJ52BuMPbRR8vl2JyQ6Vsoq/7SFg==
X-Received: by 2002:a25:9001:: with SMTP id s1mr29449505ybl.493.1548876628452;
        Wed, 30 Jan 2019 11:30:28 -0800 (PST)
Received: from localhost ([2620:10d:c091:200::5:6c95])
        by smtp.gmail.com with ESMTPSA id c127sm789304ywb.67.2019.01.30.11.30.27
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 30 Jan 2019 11:30:27 -0800 (PST)
Date: Wed, 30 Jan 2019 14:30:26 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@kernel.org>,
	Chris Down <chris@chrisdown.name>,
	Andrew Morton <akpm@linux-foundation.org>,
	Roman Gushchin <guro@fb.com>, Dennis Zhou <dennis@kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Cgroups <cgroups@vger.kernel.org>, Linux MM <linux-mm@kvack.org>,
	kernel-team@fb.com
Subject: Re: [PATCH 2/2] mm: Consider subtrees in memory.events
Message-ID: <20190130193026.GA21410@cmpxchg.org>
References: <20190128151859.GO18811@dhcp22.suse.cz>
 <20190128154150.GQ50184@devbig004.ftw2.facebook.com>
 <20190128170526.GQ18811@dhcp22.suse.cz>
 <20190128174905.GU50184@devbig004.ftw2.facebook.com>
 <20190129144306.GO18811@dhcp22.suse.cz>
 <20190129145240.GX50184@devbig004.ftw2.facebook.com>
 <20190130165058.GA18811@dhcp22.suse.cz>
 <20190130170658.GY50184@devbig004.ftw2.facebook.com>
 <CALvZod5ma62fRKqrAhMcuNT3GYT3FpRX+DCmeVr2nDg1u=9T8w@mail.gmail.com>
 <20190130192712.GA21279@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190130192712.GA21279@cmpxchg.org>
User-Agent: Mutt/1.11.2 (2019-01-07)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jan 30, 2019 at 02:27:12PM -0500, Johannes Weiner wrote:
> On Wed, Jan 30, 2019 at 11:11:44AM -0800, Shakeel Butt wrote:
> > Hi Tejun,
> > 
> > On Wed, Jan 30, 2019 at 9:07 AM Tejun Heo <tj@kernel.org> wrote:
> > >
> > > Hello, Michal.
> > >
> > > On Wed, Jan 30, 2019 at 05:50:58PM +0100, Michal Hocko wrote:
> > > > > Yeah, cgroup.events and .stat files as some of the local stats would
> > > > > be useful too, so if we don't flip memory.events we'll end up with sth
> > > > > like cgroup.events.local, memory.events.tree and memory.stats.local,
> > > > > which is gonna be hilarious.
> > > >
> > > > Why cannot we simply have memory.events_tree and be done with it? Sure
> > > > the file names are not goin to be consistent which is a minus but that
> > > > ship has already sailed some time ago.
> > >
> > > Because the overall cost of shitty interface will be way higher in the
> > > longer term.  cgroup2 interface is far from perfect but is way better
> > > than cgroup1 especially for the memory controller.  Why do you think
> > > that is?
> > >
> > 
> > I thought you are fine with the separate interface for the hierarchical events.
> 
> Every other file in cgroup2 is hierarchical, but for recursive
> memory.events you'd need to read memory.events_tree?
> 
> Do we hate our users that much? :(

FTR, I would be okay with adding .local versions to existing files
where such a behavior could be useful. But that seems to be a separate
discussion from fixing memory.events here.


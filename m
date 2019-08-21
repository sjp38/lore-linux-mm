Return-Path: <SRS0=I31T=WR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 10BDFC3A59E
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 08:16:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BF3B42332A
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 08:16:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="HCSs+psm"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BF3B42332A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6179A6B02A9; Wed, 21 Aug 2019 04:16:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5C7076B02AA; Wed, 21 Aug 2019 04:16:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 48ED86B02AB; Wed, 21 Aug 2019 04:16:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0004.hostedemail.com [216.40.44.4])
	by kanga.kvack.org (Postfix) with ESMTP id 2A7506B02A9
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 04:16:32 -0400 (EDT)
Received: from smtpin11.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id CEF2A180AD803
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 08:16:31 +0000 (UTC)
X-FDA: 75845728182.11.burst85_38f8f41542c5a
X-HE-Tag: burst85_38f8f41542c5a
X-Filterd-Recvd-Size: 5372
Received: from mail-io1-f65.google.com (mail-io1-f65.google.com [209.85.166.65])
	by imf40.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 08:16:31 +0000 (UTC)
Received: by mail-io1-f65.google.com with SMTP id j4so2781522iop.11
        for <linux-mm@kvack.org>; Wed, 21 Aug 2019 01:16:31 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=uGDTh5+56HYCkBew9+foKZeiE/fNudJnFoqmM7+OUYo=;
        b=HCSs+psmkXw2DHOSQlCbnb0AOt3RjVSPXcd2z0Mbxlup7965tPd44THP1Gungg2MBz
         JEirU57nCC5unY9vOyU/w/E9Lc3hsfImkFVLIjUu3KHw5VY3ato0BJPj9nMxDDeaRoo6
         A2m2aFBLb6/WFLwVeMOwRRYsWMQP294HWOMaT6FPHWwQzevF8KcSiLBaIKFKm95VEP9M
         HUjACVc9lTVc2Zk+ilAFSXmbpkqoXmrUSKCw7J+ALBirwTZJcEEU42lTgt/Z4Uww+giw
         BwHHAm9HyvABiSyuNjAcLZWswLN55QmOBXRaOs1PFsQTdYJDQMiUNZrX9HZV8l2GlTiQ
         XhTA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=uGDTh5+56HYCkBew9+foKZeiE/fNudJnFoqmM7+OUYo=;
        b=q1ZJAbkV345u/qxzLEIEERn2/+m/oenA2DBe48RbGhPi+XOXZjP6AlEQLFEX+qXXp0
         FKpQVUeBjAms4ulPjeB2RROWQIDVFltUwuxhr1tgSbUzo5u7FPouTp5NHid++Qe4MjCB
         2/QeBVfrcnnL5sTBmC1NCdBKI2O2WsQzSOtWsadsUW2HehnPXmIpaIRthGeXD7RsU906
         JIpIWfRGIFuEYbqj2Wba8NYJJ9iAapfXxW2z+C8+fgUrz9DuWBUHeycTI21euPWeohGe
         BHUHcD0lsh1KrSgiN/oPYSlLLutTpI4xS024xXJ4JZxZQONEmofcHz7QWfuU6rJ/71XL
         Ud2A==
X-Gm-Message-State: APjAAAWVapY7lSmtoNQRg5qPP/DA0KE585/Sqk9THawkVdPe1GHUHjll
	HDXQ6w+yVVCCdWu99YDRk2wIM/mlNPlGZC+hkgY=
X-Google-Smtp-Source: APXvYqwyoH/lVTOlgCeLi0HDcPS48cVoLvAKey9Pt7r4RBuYVk73sDWcxPhRDqSjGtjIHwoP3CW+Ae0Otq3eSgjjSOQ=
X-Received: by 2002:a05:6602:224a:: with SMTP id o10mr22041625ioo.44.1566375390835;
 Wed, 21 Aug 2019 01:16:30 -0700 (PDT)
MIME-Version: 1.0
References: <1566177486-2649-1-git-send-email-laoar.shao@gmail.com>
 <20190820213905.GB12897@tower.DHCP.thefacebook.com> <CALOAHbBSUPkw-XZBGooGZ9o7HcD5fbavG0bPDFCnYAFqqX8MGA@mail.gmail.com>
 <20190821064452.GV3111@dhcp22.suse.cz> <CALOAHbAt6nm+qSOLGTeo5s5XjQFcasQw9HJfKEEC24xVOoVxwg@mail.gmail.com>
 <20190821080516.GZ3111@dhcp22.suse.cz>
In-Reply-To: <20190821080516.GZ3111@dhcp22.suse.cz>
From: Yafang Shao <laoar.shao@gmail.com>
Date: Wed, 21 Aug 2019 16:15:54 +0800
Message-ID: <CALOAHbBJSi6R_mgh=hoPTcRXsHBb9g-_0tjEz5tWeC22cnaWRw@mail.gmail.com>
Subject: Re: [PATCH v2] mm, memcg: skip killing processes under memcg
 protection at first scan
To: Michal Hocko <mhocko@suse.com>
Cc: Roman Gushchin <guro@fb.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, 
	"linux-mm@kvack.org" <linux-mm@kvack.org>, Randy Dunlap <rdunlap@infradead.org>, 
	Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, 
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, 
	Souptick Joarder <jrdr.linux@gmail.com>, Yafang Shao <shaoyafang@didiglobal.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 21, 2019 at 4:05 PM Michal Hocko <mhocko@suse.com> wrote:
>
> On Wed 21-08-19 15:26:56, Yafang Shao wrote:
> > On Wed, Aug 21, 2019 at 2:44 PM Michal Hocko <mhocko@suse.com> wrote:
> > >
> > > On Wed 21-08-19 09:00:39, Yafang Shao wrote:
> > > [...]
> > > > More possible OOMs is also a strong side effect (and it prevent us
> > > > from using it).
> > >
> > > So why don't you use low limit if the guarantee side of min limit is too
> > > strong for you?
> >
> > Well, I don't know what the best-practice of memory.min is.
>
> It is really a workload reclaim protection. Say you have a memory
> consumer which performance characteristics would be noticeably disrupted
> by any memory reclaim which then would lead to SLA disruption. This is a
> strong requirement/QoS feature and as such comes with its demand on
> configuration.
>
> > In our plan, we want to use it to protect the top priority containers
> > (e.g. set the memory.min same with memory limit), which may latency
> > sensive. Using memory.min may sometimes decrease the refault.
> > If we set it too low, it may useless, becasue what memory.min is
> > protecting is not specified. And if there're some busrt anon memory
> > allocate in this memcg, the memory.min may can't protect any file
> > memory.
>
> I am still not seeing why you are considering guarantee (memory.min)
> rather than best practice (memory.low) here?

Let me show some examples for you.
Suppose we have three containers with different priorities, which are
high priority, medium priority and low priority.
Then we set memory.low to these containers as bellow,
high prioirty: memory.low same with memory.max
medium priroity: memory.low is 50% of memory.max
low priority: memory.low is 0

When all relcaimable pages withouth protection are reclaimed, the
reclaimer begins to reclaim the protected pages, but unforuantely it
desn't know which pages are belonging to high priority container and
which pages are belonging to medium priority container. So the
relcaimer may reclaim the high priority contianer first, and without
reclaiming the medium priority container at all.

Thanks
Yafang


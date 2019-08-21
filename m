Return-Path: <SRS0=I31T=WR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D5885C3A59E
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 08:46:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 89A4122D6D
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 08:46:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="GvYtem1i"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 89A4122D6D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 11E316B02AD; Wed, 21 Aug 2019 04:46:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0CFED6B02AE; Wed, 21 Aug 2019 04:46:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F26C66B02AF; Wed, 21 Aug 2019 04:46:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0087.hostedemail.com [216.40.44.87])
	by kanga.kvack.org (Postfix) with ESMTP id D0F6E6B02AD
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 04:46:38 -0400 (EDT)
Received: from smtpin18.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 6DCF08248AC6
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 08:46:38 +0000 (UTC)
X-FDA: 75845804076.18.lamp74_1cd33f1625948
X-HE-Tag: lamp74_1cd33f1625948
X-Filterd-Recvd-Size: 6404
Received: from mail-io1-f68.google.com (mail-io1-f68.google.com [209.85.166.68])
	by imf27.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 08:46:37 +0000 (UTC)
Received: by mail-io1-f68.google.com with SMTP id q22so3008092iog.4
        for <linux-mm@kvack.org>; Wed, 21 Aug 2019 01:46:37 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=9vCpCBojUO+rPHx+3SLl/2PGiQN3OLn9et/25UO/KkE=;
        b=GvYtem1iJQrCxZV/7A6pns2SLxvDg/PwnPLM6ILaACkYGuo7vBnidVM9tJ9Aj+A4uD
         a5fcWZGiVQfI/AQgtEQE/pPtJi2ESS17sLTwIHYMc5kPBzpr/N2wVtf/2QoUAeJ960cy
         vA2hd+CwKIqYYbm9hfeZQmL2fhKYErkVyoA4MPQx15N0dthXFudPhiGmNdT9hzyCl20a
         Wz4qdD4/nHR+RgmtGlQyOq3mxW1na3aMwmsts8rskJbhw2HqG7KZmiUk1c/SvUsIeBYR
         J3kuZBH3RxbKO2ZxvuosYhaPkwFNsVxK+NUYiME+3FVmoKCtZPe3ZttcLRIjhnhGdOX/
         Otzw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=9vCpCBojUO+rPHx+3SLl/2PGiQN3OLn9et/25UO/KkE=;
        b=WwkIpPSqLxJy+5Y1il9iPhQ7UUJIIuPp/jejvL9MCsf+LHMa9AQpDPHndLuWcq0g4+
         2T+e+z5we91wqPHZqzhkNYNTm+n6YKCytDmlHjYHeAq6vpHP3/vTbyWeiZ3SYcaiiUW3
         iLa4PB7zEvQICtJAovcRGEePg7yOGZdtEZ0w36Eu+r3Ee7xgqkdfCR2gbgPiGWufx83p
         ue29nmvAZrWMFYpgDcpMsqg6i2Vzu5ezH0zUTSLOTJQJ91HoRF+OXrgwi2wsqJukJuFp
         Ypkrctm7shE6i10MYBcQD5UjcCRUYV1sNQaYjdvDuTWKPMtyiZPOiTPhhXoieMKX5+h2
         qaQw==
X-Gm-Message-State: APjAAAWN2nUsrKV6r1IIJAV/lDYluqlVixHVLtKNeUsvVsm6C5l77bax
	0hZ8KHkxPZTModpWthnfdptYIooKkq9nWtrJ22g=
X-Google-Smtp-Source: APXvYqzKuXsC0k8qHalovyoAwUHGp+NF2SETqVfOOoBCybhCxD9EF44OgyS38jLNKdhDxrUCpC4W/co0zuIQ6z80c20=
X-Received: by 2002:a02:1981:: with SMTP id b123mr6131013jab.72.1566377197249;
 Wed, 21 Aug 2019 01:46:37 -0700 (PDT)
MIME-Version: 1.0
References: <1566177486-2649-1-git-send-email-laoar.shao@gmail.com>
 <20190820213905.GB12897@tower.DHCP.thefacebook.com> <CALOAHbBSUPkw-XZBGooGZ9o7HcD5fbavG0bPDFCnYAFqqX8MGA@mail.gmail.com>
 <20190821064452.GV3111@dhcp22.suse.cz> <CALOAHbAt6nm+qSOLGTeo5s5XjQFcasQw9HJfKEEC24xVOoVxwg@mail.gmail.com>
 <20190821080516.GZ3111@dhcp22.suse.cz> <CALOAHbBJSi6R_mgh=hoPTcRXsHBb9g-_0tjEz5tWeC22cnaWRw@mail.gmail.com>
 <20190821083457.GC3111@dhcp22.suse.cz>
In-Reply-To: <20190821083457.GC3111@dhcp22.suse.cz>
From: Yafang Shao <laoar.shao@gmail.com>
Date: Wed, 21 Aug 2019 16:46:01 +0800
Message-ID: <CALOAHbAtsAPk0zkDNY=d210P40hSeY4_ftAxGT+DeOzuqYXjzg@mail.gmail.com>
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

On Wed, Aug 21, 2019 at 4:34 PM Michal Hocko <mhocko@suse.com> wrote:
>
> On Wed 21-08-19 16:15:54, Yafang Shao wrote:
> > On Wed, Aug 21, 2019 at 4:05 PM Michal Hocko <mhocko@suse.com> wrote:
> > >
> > > On Wed 21-08-19 15:26:56, Yafang Shao wrote:
> > > > On Wed, Aug 21, 2019 at 2:44 PM Michal Hocko <mhocko@suse.com> wrote:
> > > > >
> > > > > On Wed 21-08-19 09:00:39, Yafang Shao wrote:
> > > > > [...]
> > > > > > More possible OOMs is also a strong side effect (and it prevent us
> > > > > > from using it).
> > > > >
> > > > > So why don't you use low limit if the guarantee side of min limit is too
> > > > > strong for you?
> > > >
> > > > Well, I don't know what the best-practice of memory.min is.
> > >
> > > It is really a workload reclaim protection. Say you have a memory
> > > consumer which performance characteristics would be noticeably disrupted
> > > by any memory reclaim which then would lead to SLA disruption. This is a
> > > strong requirement/QoS feature and as such comes with its demand on
> > > configuration.
> > >
> > > > In our plan, we want to use it to protect the top priority containers
> > > > (e.g. set the memory.min same with memory limit), which may latency
> > > > sensive. Using memory.min may sometimes decrease the refault.
> > > > If we set it too low, it may useless, becasue what memory.min is
> > > > protecting is not specified. And if there're some busrt anon memory
> > > > allocate in this memcg, the memory.min may can't protect any file
> > > > memory.
> > >
> > > I am still not seeing why you are considering guarantee (memory.min)
> > > rather than best practice (memory.low) here?
> >
> > Let me show some examples for you.
> > Suppose we have three containers with different priorities, which are
> > high priority, medium priority and low priority.
> > Then we set memory.low to these containers as bellow,
> > high prioirty: memory.low same with memory.max
> > medium priroity: memory.low is 50% of memory.max
> > low priority: memory.low is 0
> >
> > When all relcaimable pages withouth protection are reclaimed, the
> > reclaimer begins to reclaim the protected pages, but unforuantely it
> > desn't know which pages are belonging to high priority container and
> > which pages are belonging to medium priority container. So the
> > relcaimer may reclaim the high priority contianer first, and without
> > reclaiming the medium priority container at all.
>
> Hmm, it is hard to comment on this configuration without knowing what is
> the overall consumption of all the three. In any case reclaiming all of
> the reclaimable memory means that you have actually reclaimed full of
> the low and half of the medium container to even start hitting on high
> priority one. When there are only low priority protected containers then
> they will get reclaimed proportionally to their size.

Right.
I think priority-based reclaimer (different priorities has differecnt
proportional scan count ) would be more fine, while memroy.low is not
easy to practice in this situation.

Thanks
Yafang


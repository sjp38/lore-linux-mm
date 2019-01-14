Return-Path: <SRS0=uJng=PW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 389B2C43387
	for <linux-mm@archiver.kernel.org>; Mon, 14 Jan 2019 20:18:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ED12E2064C
	for <linux-mm@archiver.kernel.org>; Mon, 14 Jan 2019 20:18:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="usVYOPw9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ED12E2064C
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 88E198E0003; Mon, 14 Jan 2019 15:18:21 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8470E8E0002; Mon, 14 Jan 2019 15:18:21 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 752548E0003; Mon, 14 Jan 2019 15:18:21 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id 441478E0002
	for <linux-mm@kvack.org>; Mon, 14 Jan 2019 15:18:21 -0500 (EST)
Received: by mail-yb1-f199.google.com with SMTP id 124so148845ybb.9
        for <linux-mm@kvack.org>; Mon, 14 Jan 2019 12:18:21 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=ptzNydK5Q1PCEDwfDmjHWSEiaPwMsBePibwbeCNfTt0=;
        b=mEPKKYJy+68kCY5gvIAFCBU5eM6lbXcDESDhJJWeJC/0OWIA1njcNLn6drKvgMEmgK
         Mn4fkmbrUvZr/7Q2kTOcLDX8bWC1PgMBrHfnBqh4WT48Od+jsnlM0Lrhb2h4jjsCLNF9
         F6efnWo91XwF1F6GV+2GH7wR3FVmZd2l7ykD4xgf0wSkxNwbkrhSmfzXqmpfdUmLkOvs
         3YxOn+34+GI8OmJUuoYLolgq2Nka7K0Ud0yvmMxG+MKx28GkfzyPylnSCyNKYc5Ui6nz
         r8PeJLgDcyKKIYHst7op6tE5YSVJXqWyZLaGrS5RitUw8nxVm4di/HBFC05DlFDyxV2c
         gWtw==
X-Gm-Message-State: AJcUukd+cmIZOFFOX2ueuzcWpAnBsvq9W5N8+SWtx0kCA0TLLrjfN/Dn
	5KZhPSSuJFkAAhkUJmonerJTrEsHyB3KcO43B1KLRsosGUCCUBKZC+UU9WmbRokJbx9TuIQTYxV
	kXH71t3dDHQDnjy3gOYT+tYXXs3R0sT08OPRnzfb1WQCEig2jvPFL1Gr1yNKnhQMlwXT77ZT7Cd
	YrOmb/Jsh1yPsSNiD6viFcMgb63tolSdYPKroFLbLqgMHG58xCSgy0THuIKeC05DbXgBzN/JZgA
	BxaAZ5mIUpXcgpOM6PjRcWRvR2yJ3kZqaSMTVYXdbum8xVPv/zdBzTiDaVvG4TybB+aajNtLgMm
	aN6o3GuLujwnIq4wX1H5+2kxEPf8F4LqjgxD7cxLgoPqjO1skV3Qg7rOMd/gFz2CF+PIItU2C0Z
	0
X-Received: by 2002:a25:20c6:: with SMTP id g189mr156018ybg.303.1547497100904;
        Mon, 14 Jan 2019 12:18:20 -0800 (PST)
X-Received: by 2002:a25:20c6:: with SMTP id g189mr155950ybg.303.1547497099823;
        Mon, 14 Jan 2019 12:18:19 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547497099; cv=none;
        d=google.com; s=arc-20160816;
        b=OduLn28xQktPfe9Lry2NVnPfVU4HQM7NVqEVoVLJXPSe2rCnmnwcYoUHsNyHMstRhe
         FFrelfZq8eMhmnT5rJM+sUTHSdaLRnUPpd0QzUelpQEsvivFoblKUgJoZStEy6JL62Uj
         N6dnFc5q6CrK7nt91ZQaVOCcRxnLo82/ff+Opw0dYpYDsHZgBKp1Ov+O6tAYTF9DiuEL
         xP6nC8PzMBxwvWGkvgHeQV5b3HRADelcUQ+kYbBmFPm0eZW5JCMeTKQHz9XSl4VSqH/F
         ByfRPjQux+tL5+OqJ178gCPk2MzOxnS39qToFnzaqzgfePiRh/cFHs1TY3FTFi1Rzvh1
         +Djg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=ptzNydK5Q1PCEDwfDmjHWSEiaPwMsBePibwbeCNfTt0=;
        b=c3B8e146JnV51uaFFtTWY4K3ySfH1A5WMk7hPtrks2CF8CdLz0j88BdbU0UbxdzF6r
         dYO785o3wSfnd4ZNb9efdw7vzgEPPFGa1UOBBiMZo4zhsdr+uNw7TCGQTUnOWom3CEqW
         zMCFB0VVaVTdHTa0pJIg2p7LDGhtlNaipoLQl7/MdeNwyignhT4XwWSdIamlQZn+9nPo
         9M6ap5QQP0/D+f/BOLREwKZcoaV/dijsbGXJzW/UpolHZ0sQj05bewEcRFdMTyxK/Mpe
         PjkkDCmSOY8VM0TZKwj7wcO6hbgNcdfy4jdDEIg+HQz08KG60S8cOzR3mowOcjClaATx
         BB+w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=usVYOPw9;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q64sor266984ywd.173.2019.01.14.12.18.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 14 Jan 2019 12:18:19 -0800 (PST)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=usVYOPw9;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=ptzNydK5Q1PCEDwfDmjHWSEiaPwMsBePibwbeCNfTt0=;
        b=usVYOPw9XXkqwoIO39XNY5sffSx9x1nFMRLmaz3VT+CmOEugT2/St7wyNWeLqm200i
         sZu5YUrtr1IQCCSXHYrO1AvsGKK4b8QpjIqkrmC+KdgxEKfUNFwpFkvTo2Zz2q4PYsFG
         WTvHay+dKR8GlcjGluV9AGuRN1j1kok9Nx/aTVWKHcvRT+lLVteAaaBvuuvWhwNL9RQX
         jSnRwv/++jnfkozDPdam6qVe64rDLMuThn6YbCJ+7vJz6G9v7soosaaY7/Z3ubSkY76D
         rI91F6ya3blDaf7Yf+TuW3wvr/m3bmuCgN2OToSzw4ZQb99093m/5gM0Mj4sP2wUuq4H
         49XQ==
X-Google-Smtp-Source: ALg8bN4FXjn4pOrbWmB91djMJ9IikbMNtEpPDKFVEvbzmJGsLAVkWNPM3aI5oDKuZi4IBJsj36JFv9VgyTMv+q1hed8=
X-Received: by 2002:a81:60c4:: with SMTP id u187mr169489ywb.345.1547497099231;
 Mon, 14 Jan 2019 12:18:19 -0800 (PST)
MIME-Version: 1.0
References: <20190110174432.82064-1-shakeelb@google.com> <20190111205948.GA4591@cmpxchg.org>
 <CALvZod7O2CJuhbuLUy9R-E4dTgL4WBg8CayW_AFnCCG6KCDjUA@mail.gmail.com> <20190113183402.GD1578@dhcp22.suse.cz>
In-Reply-To: <20190113183402.GD1578@dhcp22.suse.cz>
From: Shakeel Butt <shakeelb@google.com>
Date: Mon, 14 Jan 2019 12:18:07 -0800
Message-ID:
 <CALvZod6paX4_vtgP8AJm5PmW_zA_ecLLP2qTvQz8rRyKticgDg@mail.gmail.com>
Subject: Re: [PATCH v3] memcg: schedule high reclaim for remote memcgs on high_work
To: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Vladimir Davydov <vdavydov.dev@gmail.com>, Cgroups <cgroups@vger.kernel.org>, 
	Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190114201807.qhIlFVg0LKi-ksYYJob9mvWk8CivIOI3RbexIaHRCw8@z>

On Sun, Jan 13, 2019 at 10:34 AM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Fri 11-01-19 14:54:32, Shakeel Butt wrote:
> > Hi Johannes,
> >
> > On Fri, Jan 11, 2019 at 12:59 PM Johannes Weiner <hannes@cmpxchg.org> wrote:
> > >
> > > Hi Shakeel,
> > >
> > > On Thu, Jan 10, 2019 at 09:44:32AM -0800, Shakeel Butt wrote:
> > > > If a memcg is over high limit, memory reclaim is scheduled to run on
> > > > return-to-userland.  However it is assumed that the memcg is the current
> > > > process's memcg.  With remote memcg charging for kmem or swapping in a
> > > > page charged to remote memcg, current process can trigger reclaim on
> > > > remote memcg.  So, schduling reclaim on return-to-userland for remote
> > > > memcgs will ignore the high reclaim altogether. So, record the memcg
> > > > needing high reclaim and trigger high reclaim for that memcg on
> > > > return-to-userland.  However if the memcg is already recorded for high
> > > > reclaim and the recorded memcg is not the descendant of the the memcg
> > > > needing high reclaim, punt the high reclaim to the work queue.
> > >
> > > The idea behind remote charging is that the thread allocating the
> > > memory is not responsible for that memory, but a different cgroup
> > > is. Why would the same thread then have to work off any high excess
> > > this could produce in that unrelated group?
> > >
> > > Say you have a inotify/dnotify listener that is restricted in its
> > > memory use - now everybody sending notification events from outside
> > > that listener's group would get throttled on a cgroup over which it
> > > has no control. That sounds like a recipe for priority inversions.
> > >
> > > It seems to me we should only do reclaim-on-return when current is in
> > > the ill-behaved cgroup, and punt everything else - interrupts and
> > > remote charges - to the workqueue.
> >
> > This is what v1 of this patch was doing but Michal suggested to do
> > what this version is doing. Michal's argument was that the current is
> > already charging and maybe reclaiming a remote memcg then why not do
> > the high excess reclaim as well.
>
> Johannes has a good point about the priority inversion problems which I
> haven't thought about.
>
> > Personally I don't have any strong opinion either way. What I actually
> > wanted was to punt this high reclaim to some process in that remote
> > memcg. However I didn't explore much on that direction thinking if
> > that complexity is worth it. Maybe I should at least explore it, so,
> > we can compare the solutions. What do you think?
>
> My question would be whether we really care all that much. Do we know of
> workloads which would generate a large high limit excess?
>

The current semantics of memory.high is that it can be breached under
extreme conditions. However any workload where memory.high is used and
a lot of remote memcg charging happens (inotify/dnotify example given
by Johannes or swapping in tmpfs file or shared memory region) the
memory.high breach will become common.

Shakeel


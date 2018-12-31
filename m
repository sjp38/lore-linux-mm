Return-Path: <SRS0=02Vf=PI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B3105C43387
	for <linux-mm@archiver.kernel.org>; Mon, 31 Dec 2018 04:00:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5EE0220815
	for <linux-mm@archiver.kernel.org>; Mon, 31 Dec 2018 04:00:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="WsMYvGBB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5EE0220815
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DB6D78E0078; Sun, 30 Dec 2018 23:00:06 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D3DA18E005B; Sun, 30 Dec 2018 23:00:06 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BDD4A8E0078; Sun, 30 Dec 2018 23:00:06 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 89F0F8E005B
	for <linux-mm@kvack.org>; Sun, 30 Dec 2018 23:00:06 -0500 (EST)
Received: by mail-yw1-f71.google.com with SMTP id t17so19017633ywc.23
        for <linux-mm@kvack.org>; Sun, 30 Dec 2018 20:00:06 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=eF0ABIO04VeZkpOY0d/MbtAbWyc/7osI9Wsdii8Iryw=;
        b=U6PZJIzjDIz9k72o10dDcWjoRkT+5OwU39/dQUQmZgD30xJlQW0rPVYLv70F2Wu5dG
         /1cgD/ODSkYwBnW8kT1XyZW+Czpovd6U8BIc5kVsLCJa6Uorqjg4Aufe3z/WPnx6fLRs
         G9N4egY3aLwpuJPrR0WtAj0gcdv2R1Qfnlxd2bTa3uf6Uz9PXHoVTruNpY5Zu0o+QXf5
         0XgxyNTS7iuIlbMJyDNZRD5MvPWrVG0R7Is538EiD01ykYbdA2IPL1k1X0cV7zgFRiqg
         sDxo8eRWow+fsjapScv7v0BuCI1zGoZWNqxrLm1lVdIywhIldK2SO5vdbIMNVViMqqKM
         v6TA==
X-Gm-Message-State: AA+aEWanIQpuUqXemWRwOFKDF0FhBvXvwcfcNW99PsQMSk/oaWhaBDDp
	pTGKLkx7vWRBQzzgxtsvoZAVbFeBNMc2yKfJ4V3XOwSmSk9aU8/F9fH20pJcRtlkJDL/p2Q2ytx
	vMtgQeHMMolo06CIL3sOB8fibAoyFlgXkCf5ZBfDMveZC03g6oiRrteaqtOkJB8wneTyEfhnafr
	yXCM6wjLcwZjwlIhtyV7ifyCaLnl2l8gNjgC04A2G4yWZ51sdLBV1doycM156zlXPEa8TmjX7S2
	KYDMeVmMeIimKjUDQjiluLe07uBIb0kFyaF3n4Rh7GgE3KItOb+AtZ3yyEGmyn+vr7AEBdKgz6+
	Yik8OLFqiV6YVSBgENi/bmkAH16A4CxTBLJvqvXIdipova3kNXequOkTyxD5f1+s1lmSLhG4/Bt
	e
X-Received: by 2002:a81:ac21:: with SMTP id k33mr36709009ywh.463.1546228806127;
        Sun, 30 Dec 2018 20:00:06 -0800 (PST)
X-Received: by 2002:a81:ac21:: with SMTP id k33mr36708980ywh.463.1546228805514;
        Sun, 30 Dec 2018 20:00:05 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546228805; cv=none;
        d=google.com; s=arc-20160816;
        b=bTVGbKzZhvEL+SNL6ayyOQuIcN27WhMR/LdPX8EfI2jF3LBgl+ybZqnO8AsKG9hPAP
         bsjYFls2BGoOf7x68RCEKX7PSSf0BhkinMXASVSqAA0vifYW47y5tIcoaNZU1JchQmPf
         iW8EonDGTyNWH+2jXes0EQm1WfANldLcr5q6zoocj+bQ4LKl1qDLeZYL5CUgnbizSh63
         FL3F2YGVp2cZeDmNNH9kDVPPqvVBaersRPeaDUwW3LvXfSlOdDA5/FTI2bvjsc1HfUr1
         2frHWs0Gil1gEVAUBb5ZOeqqCAqmuE1qqJuPzHuM5F1hrFuZgk+NCdKTKJV3/xanumd6
         d4LQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=eF0ABIO04VeZkpOY0d/MbtAbWyc/7osI9Wsdii8Iryw=;
        b=Iv4iaBAbNLegY5X1htTv+KQWHPFYA7Q58IXXj/lnUrxL6UZ5nMWc2wf+EoMOuiYrrv
         XTZeR7lr5QklIW4ffXvxU+8d9WQXdbQ27nw+0MOfkVBn9nrwjn2eXSiRuTH0IzklxkPG
         3udn53YEXQAsSViRFLfRIkSB/Pz/r7V4LTABMTRqT4LXz5RovajdoJPPHpAiXmnQXe0B
         FoMLIDz5PR4o8evZPEJs0m5/VvUCpBsmPKjkQjZqk/X7yJT5iVzQH6zGJmK3qZX5aF+W
         pZGg+gSjG3CGiodLT240KG7DfD+ejpDA1MfLCE4JVY0aGJ2WkOX5twkhuzZcyGMjv0jd
         Al3A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=WsMYvGBB;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d9sor3604202ybc.199.2018.12.30.20.00.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 30 Dec 2018 20:00:05 -0800 (PST)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=WsMYvGBB;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=eF0ABIO04VeZkpOY0d/MbtAbWyc/7osI9Wsdii8Iryw=;
        b=WsMYvGBBN2/J5TQQBVcqovv2bEfNjdCyIRg5kbp1wjhY/Prghg1P1M4P6CeojjVQXN
         +3Ld8voPys4iM6gA6ISn3mxmEZWHubo/kAKi1kehK/TgFErskZuHba6Ezpbjf1XxkTw/
         4Xgl/ptU9djk0dAr3/bz5veQ8TwQhYa4Hj5sH2Yl0OGhz20Uue2gr0hRvyIYzXuf2uUy
         jpYnUAZAKEsQeguKQCsNWjQ6ml7Pt3F1WgAjP/s3ws5a4k80Vv6tr565xOdRMKI91q4a
         PuXhoD0W8N7KzOZhNNwE2eTAl/5RYxCk2Ko49roCooUUhE6e+XQR0/EWtRMVZXF+XcqB
         Cmww==
X-Google-Smtp-Source: ALg8bN4HAL0f10ML47/BEy5ZzmC8D6GegrQAY6kSTd7bulovhCXgr9ECCaW1Iun1vE9ts3AKBkL+jH2EmSF8qvxkQ68=
X-Received: by 2002:a25:c5c7:: with SMTP id v190mr24695789ybe.377.1546228804773;
 Sun, 30 Dec 2018 20:00:04 -0800 (PST)
MIME-Version: 1.0
References: <20181229015524.222741-1-shakeelb@google.com> <20181229073325.GZ16738@dhcp22.suse.cz>
 <20181229095215.nbcijqacw5b6aho7@breakpoint.cc> <20181229100615.GB16738@dhcp22.suse.cz>
 <CALvZod7v-CC1XipLAerFj1Zp_M=qXZq6MzDL4pubJMTRCsMFNw@mail.gmail.com>
 <20181230074513.GA22445@dhcp22.suse.cz> <20181230080028.GB22445@dhcp22.suse.cz>
In-Reply-To: <20181230080028.GB22445@dhcp22.suse.cz>
From: Shakeel Butt <shakeelb@google.com>
Date: Sun, 30 Dec 2018 19:59:53 -0800
Message-ID:
 <CALvZod6Ty30uQjJF8KZf=RS5djULaLVggYv_1WFrKJWaYa6EHw@mail.gmail.com>
Subject: Re: [PATCH] netfilter: account ebt_table_info to kmemcg
To: Michal Hocko <mhocko@kernel.org>
Cc: Florian Westphal <fw@strlen.de>, Pablo Neira Ayuso <pablo@netfilter.org>, 
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, Roopa Prabhu <roopa@cumulusnetworks.com>, 
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Linux MM <linux-mm@kvack.org>, netfilter-devel@vger.kernel.org, 
	coreteam@netfilter.org, bridge@lists.linux-foundation.org, 
	LKML <linux-kernel@vger.kernel.org>, 
	syzbot+7713f3aa67be76b1552c@syzkaller.appspotmail.com
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20181231035953.QHObS_AZnK3W0xiAqYb6FWoLIoY6turjX-GUJGEU5Z8@z>

On Sun, Dec 30, 2018 at 12:00 AM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Sun 30-12-18 08:45:13, Michal Hocko wrote:
> > On Sat 29-12-18 11:34:29, Shakeel Butt wrote:
> > > On Sat, Dec 29, 2018 at 2:06 AM Michal Hocko <mhocko@kernel.org> wrote:
> > > >
> > > > On Sat 29-12-18 10:52:15, Florian Westphal wrote:
> > > > > Michal Hocko <mhocko@kernel.org> wrote:
> > > > > > On Fri 28-12-18 17:55:24, Shakeel Butt wrote:
> > > > > > > The [ip,ip6,arp]_tables use x_tables_info internally and the underlying
> > > > > > > memory is already accounted to kmemcg. Do the same for ebtables. The
> > > > > > > syzbot, by using setsockopt(EBT_SO_SET_ENTRIES), was able to OOM the
> > > > > > > whole system from a restricted memcg, a potential DoS.
> > > > > >
> > > > > > What is the lifetime of these objects? Are they bound to any process?
> > > > >
> > > > > No, they are not.
> > > > > They are free'd only when userspace requests it or the netns is
> > > > > destroyed.
> > > >
> > > > Then this is problematic, because the oom killer is not able to
> > > > guarantee the hard limit and so the excessive memory consumption cannot
> > > > be really contained. As a result the memcg will be basically useless
> > > > until somebody tears down the charged objects by other means. The memcg
> > > > oom killer will surely kill all the existing tasks in the cgroup and
> > > > this could somehow reduce the problem. Maybe this is sufficient for
> > > > some usecases but that should be properly analyzed and described in the
> > > > changelog.
> > > >
> > >
> > > Can you explain why you think the memcg hard limit will not be
> > > enforced? From what I understand, the memcg oom-killer will kill the
> > > allocating processes as you have mentioned. We do force charging for
> > > very limited conditions but here the memcg oom-killer will take care
> > > of
> >
> > I was talking about the force charge part. Depending on a specific
> > allocation and its life time this can gradually get us over hard limit
> > without any bound theoretically.
>
> Forgot to mention. Since b8c8a338f75e ("Revert "vmalloc: back off when
> the current task is killed"") there is no way to bail out from the
> vmalloc allocation loop so if the request is really large then the memcg
> oom will not help. Is that a problem here?
>

Yes, I think it will be an issue here.

> Maybe it is time to revisit fatal_signal_pending check.

Yes, we will need something to handle the memcg OOM. I will think more
on that front or if you have any ideas, please do propose.

thanks,
Shakeel


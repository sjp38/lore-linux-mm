Return-Path: <SRS0=O33Z=PL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 291D3C43387
	for <linux-mm@archiver.kernel.org>; Thu,  3 Jan 2019 20:53:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CF61D217F5
	for <linux-mm@archiver.kernel.org>; Thu,  3 Jan 2019 20:53:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="sTsQZeQd"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CF61D217F5
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5B0DB8E00B1; Thu,  3 Jan 2019 15:53:08 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 539D58E00AE; Thu,  3 Jan 2019 15:53:08 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3DB448E00B1; Thu,  3 Jan 2019 15:53:08 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0A4438E00AE
	for <linux-mm@kvack.org>; Thu,  3 Jan 2019 15:53:08 -0500 (EST)
Received: by mail-yw1-f72.google.com with SMTP id f10so22510745ywc.21
        for <linux-mm@kvack.org>; Thu, 03 Jan 2019 12:53:08 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=GRC+e8lqJOGosZywWMxAPn3OsxYIJb83p4O3nDfq6mg=;
        b=gctlidaTNBD+WVDoONt8QAq9z7GDOmZfLYccc0cUeKyJpT2PWT7UbrFhNTHD/PNFE7
         1B2mv4wZK9WUvXh2u3IA7UJcmxcbHdfRH5x00CFld+i4AS17zwJZF/mQsoLI50hWPQGl
         TaSwFNEAW8xU/rF4UbstvEBZfDOyBKdQjGbtsLvwsrudWEcESHpt45VHZWwsWg1iQv6M
         OwJblO2itzDHYrYwDbiGFDBjnjnkZPg3km0+3vfnbJrkQl3Alem2+ZzwUeWfBpdb2QRr
         RZpxIWNxEpZigsOm0NDMlGtPsHxsZ6eejh+8A7P8aN0rZTrGmIq6HMfiPD30AVT+QRKb
         KtEw==
X-Gm-Message-State: AJcUukfaBzOhbpAhUNB6KWnUh6dBxljTpj2w4Mr6PmzmKD31ftCpQ0tM
	sXhZrR6lNPTiuuDz2JWB0DBRYuBMqWDithEtKkurnWSzD3D2tdpTBuHNTs8vJWqLfbjJxeiYHzd
	pshblnjy1sAEFqYPiIM/K/mk2+pEqrd8IRqQSfoZzw2ZbHbPIFKlAybRaasBFTFiP/QSXBkuTRN
	mJqPClWw8IutVrKfsucH/N6SSDANVTi4Enz2kC30HG+tJpLWVAabskLmQJdomdMLNV6eGunpfyp
	S/NXivGSTn3jrDJgc/a6nmi6CQW3DJJs52q8WM3cTLEWLrlRRudrxUxs4DTQpVkUtu+9+hQEWB2
	Gwrb/+Zkc7Nr/FJ3cmvcnWEaoz2h1X8ziZX7xqM2u30COI+9z20kY0l/kzTC//EMfrKm7fLU7vv
	F
X-Received: by 2002:a25:3213:: with SMTP id y19mr47937436yby.5.1546548787555;
        Thu, 03 Jan 2019 12:53:07 -0800 (PST)
X-Received: by 2002:a25:3213:: with SMTP id y19mr47937409yby.5.1546548786815;
        Thu, 03 Jan 2019 12:53:06 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546548786; cv=none;
        d=google.com; s=arc-20160816;
        b=V3PildB7gVCn42oeVa7xyH4i7qpL0xjxmrcf6YjI6aAmEV/9ZHDA1KhrUpF/rzlD0a
         7Qp7TSk6cbP7OIWE6A5EJwphQaW8zrZbxNjASobzi4Ub90mWtUPCSy2WTBli8Y0L0b/v
         6E+BzueObx7FFxrhADE56qTRXsdzMIl6vkRAqxuFn+a/HnBjEb/7JcDx9tHVZCjUvxpy
         cwCQ45chsUt25zEUZrTzX1039spqHONn73fF92R7Q3fvQJzrN1HzERFq28vtxy/cHJCr
         fyWLRU+mPgbLPH+1039dSbn0xRTgmwANNDXiS5SnXflPXzPCy6sRfa2BvTVgf3bwVar9
         nVlw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=GRC+e8lqJOGosZywWMxAPn3OsxYIJb83p4O3nDfq6mg=;
        b=oRqITPdPltpp4VJPKjlqKNid8HY57EfVPzz57XW1guz+YTrAap65EF7K3EPEvu8uSn
         t7auyGxrlx9EVFNkPEEwESYp9uuGtWCRz3vUaeE615fSVDITF64L5WSsQ0ia6HqnjPAu
         lyxv80XEdtzCDAz1sMAmQWQbeU1mszJqe9Mhg1wjoGQvKvIiWO7Qp7TyJTuagjOYHWqw
         N1Pz3ykX6DCS4Q7W2JSTKtir+mXC0nS/RheDH5I4QYgfbMjLtXo0P9g2i51MZJAufoov
         vAmYPA6BWKKhu2Y4kN72gvKwzniBKycbrlEmtdVVSmbg9np3w6PfJ6Uggfvi+dH30Xpp
         BOkA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=sTsQZeQd;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d184sor2954256ybf.13.2019.01.03.12.53.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 03 Jan 2019 12:53:06 -0800 (PST)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=sTsQZeQd;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=GRC+e8lqJOGosZywWMxAPn3OsxYIJb83p4O3nDfq6mg=;
        b=sTsQZeQdrG8zu+wzyVKP746NktY7jBlU+tChfEIcRJgLTncpDFU6vVRJsCGUHNq/oH
         p3bTNNHUp3ojsKqo3qBu2iDAPGwlp734YhtgVR8tFcExKOoGed5h9G9mptzYFnLm0X5w
         4QbyKY41jyS3DBYk77kruQBX37U2WDyfp2VYgCoh/VKAqFNoiYQArxVGUyS7EsRfUqmo
         RaHpGpyjYTD4m3lq1dw1GVT2Ri9RnqLjpNVWeuR4bXtm29e2zKeSvB8kxvI9t2GCL78p
         GFdUsPo0lhkzot59BDcpNcU38qUl1QH/ZLKi8BWQOuMOEkdlD+dcJgC73bsKkSwfTJ6z
         g2qw==
X-Google-Smtp-Source: ALg8bN4doCvWl/JB8l+4c0QFW7VaYDV4rj7A06Pi28x2T5ow7hUnfvDe6+QeYO2uRoJS3LfHJFylK7r1+jPmttgO4mM=
X-Received: by 2002:a5b:f01:: with SMTP id x1mr44935147ybr.464.1546548785896;
 Thu, 03 Jan 2019 12:53:05 -0800 (PST)
MIME-Version: 1.0
References: <20181229015524.222741-1-shakeelb@google.com> <20181229073325.GZ16738@dhcp22.suse.cz>
 <20181229095215.nbcijqacw5b6aho7@breakpoint.cc> <20181229100615.GB16738@dhcp22.suse.cz>
 <CALvZod7v-CC1XipLAerFj1Zp_M=qXZq6MzDL4pubJMTRCsMFNw@mail.gmail.com>
 <20181230074513.GA22445@dhcp22.suse.cz> <20181230080028.GB22445@dhcp22.suse.cz>
 <CALvZod6Ty30uQjJF8KZf=RS5djULaLVggYv_1WFrKJWaYa6EHw@mail.gmail.com> <20181231101158.GC22445@dhcp22.suse.cz>
In-Reply-To: <20181231101158.GC22445@dhcp22.suse.cz>
From: Shakeel Butt <shakeelb@google.com>
Date: Thu, 3 Jan 2019 12:52:54 -0800
Message-ID:
 <CALvZod4sQ7ZEwfEefoNUeso2Va255x0jNgwOVZSU-b7+CevQuQ@mail.gmail.com>
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
Message-ID: <20190103205254.RTjMsgUkXYpOaV78kwLWOzo2x1Y5ls-0tbyC3aguHP8@z>

On Mon, Dec 31, 2018 at 2:12 AM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Sun 30-12-18 19:59:53, Shakeel Butt wrote:
> > On Sun, Dec 30, 2018 at 12:00 AM Michal Hocko <mhocko@kernel.org> wrote:
> > >
> > > On Sun 30-12-18 08:45:13, Michal Hocko wrote:
> > > > On Sat 29-12-18 11:34:29, Shakeel Butt wrote:
> > > > > On Sat, Dec 29, 2018 at 2:06 AM Michal Hocko <mhocko@kernel.org> wrote:
> > > > > >
> > > > > > On Sat 29-12-18 10:52:15, Florian Westphal wrote:
> > > > > > > Michal Hocko <mhocko@kernel.org> wrote:
> > > > > > > > On Fri 28-12-18 17:55:24, Shakeel Butt wrote:
> > > > > > > > > The [ip,ip6,arp]_tables use x_tables_info internally and the underlying
> > > > > > > > > memory is already accounted to kmemcg. Do the same for ebtables. The
> > > > > > > > > syzbot, by using setsockopt(EBT_SO_SET_ENTRIES), was able to OOM the
> > > > > > > > > whole system from a restricted memcg, a potential DoS.
> > > > > > > >
> > > > > > > > What is the lifetime of these objects? Are they bound to any process?
> > > > > > >
> > > > > > > No, they are not.
> > > > > > > They are free'd only when userspace requests it or the netns is
> > > > > > > destroyed.
> > > > > >
> > > > > > Then this is problematic, because the oom killer is not able to
> > > > > > guarantee the hard limit and so the excessive memory consumption cannot
> > > > > > be really contained. As a result the memcg will be basically useless
> > > > > > until somebody tears down the charged objects by other means. The memcg
> > > > > > oom killer will surely kill all the existing tasks in the cgroup and
> > > > > > this could somehow reduce the problem. Maybe this is sufficient for
> > > > > > some usecases but that should be properly analyzed and described in the
> > > > > > changelog.
> > > > > >
> > > > >
> > > > > Can you explain why you think the memcg hard limit will not be
> > > > > enforced? From what I understand, the memcg oom-killer will kill the
> > > > > allocating processes as you have mentioned. We do force charging for
> > > > > very limited conditions but here the memcg oom-killer will take care
> > > > > of
> > > >
> > > > I was talking about the force charge part. Depending on a specific
> > > > allocation and its life time this can gradually get us over hard limit
> > > > without any bound theoretically.
> > >
> > > Forgot to mention. Since b8c8a338f75e ("Revert "vmalloc: back off when
> > > the current task is killed"") there is no way to bail out from the
> > > vmalloc allocation loop so if the request is really large then the memcg
> > > oom will not help. Is that a problem here?
> > >
> >
> > Yes, I think it will be an issue here.
> >
> > > Maybe it is time to revisit fatal_signal_pending check.
> >
> > Yes, we will need something to handle the memcg OOM. I will think more
> > on that front or if you have any ideas, please do propose.
>
> I can see three options here:
>         - do not force charge on memcg oom or introduce a limited charge
>           overflow (reserves basically).
>         - revert the revert and reintroduce the fatal_signal_pending
>           check into vmalloc
>         - be more specific and check tsk_is_oom_victim in vmalloc and
>           fail
>

I think for the long term solution we might need something similar to
memcg oom reserves (1) but for quick fix I think we can do the
combination of (2) and (3).

Shakeel


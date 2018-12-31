Return-Path: <SRS0=02Vf=PI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 04C64C43387
	for <linux-mm@archiver.kernel.org>; Mon, 31 Dec 2018 04:01:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ABF7520815
	for <linux-mm@archiver.kernel.org>; Mon, 31 Dec 2018 04:01:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="RsuU+lvf"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ABF7520815
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5C5498E0079; Sun, 30 Dec 2018 23:01:08 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 54E338E005B; Sun, 30 Dec 2018 23:01:08 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3EEF98E0079; Sun, 30 Dec 2018 23:01:08 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0B3AA8E005B
	for <linux-mm@kvack.org>; Sun, 30 Dec 2018 23:01:08 -0500 (EST)
Received: by mail-yw1-f71.google.com with SMTP id u126so19278011ywb.0
        for <linux-mm@kvack.org>; Sun, 30 Dec 2018 20:01:08 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=HucXhT1A5BsfCWwXDCGEmDntqGT95qD9mv34uGfHnxM=;
        b=JCdpfr6bQ1wN8ov/F2R5h5im7bsGjQMIMuSy2IgjmIUO1nsHhYu9tiCKWB+GSXCeWz
         WiP+Iqn8PFoJnHdmh1Uij99Hjr0jP/izBGDk1JQ2JCXK/uHeejMDS/K9O5WFDbo0pcnT
         8eV74bU5YizvOlqW15uNPJf+vDEwg/UwDJ2oC4Z2Q4DM7bbGEek6DCH+1SXoGaWmuMwJ
         XVvd9+SK+EFJIVuKcIu8TQOm6PLP9iAiOuukeDj21gAweTpCkFmlzxlXCfroDsAZ6MgA
         LcZuDbECSO9oD8tIIjL3OFwqhaOhQ0/DR6R9jcM57YPaN50xl9a2GBdQlc1Um+KO+7O8
         ci0Q==
X-Gm-Message-State: AJcUukdC+S9aJQ381d8poXHnYH1ZNFUSrhNNqDL/+fxSOB/BOyWq2wOB
	9cRG2YI6qd7C+VCvukvWePIpkS1HYkHKVCnKTZsDqY3ARXroD/oM6SEkAxksQXWMTpM5/vTzO9i
	z/3mh5jJrqz3tNCJ6Ro+BcxQMjwCYq/WtpyN9zeI16jM0dMOW+sY+n9rEDmS9qdI0o1DH1wa27D
	WLEKMOABGw6BWJt/1tuHtcNrSWhmGxgEJEsUnHNkWohBVfxzQEEyWu5g4MCyph93QTI6WuimTH1
	SAV/InuYzTk/8JJLhLTQhHz+z0XflY6ZNrzzMg7/m2AQva+T9YNASjlG9907dpdDjwMF1YBvTop
	oK3G+veX44te/NxHOTmxwpfCY3y3sJTtauLWK1EfzUvbxsVNkzC0rieFAicTm8CnJsXHJg4GwCO
	f
X-Received: by 2002:a25:2a4f:: with SMTP id q76mr22484558ybq.141.1546228867800;
        Sun, 30 Dec 2018 20:01:07 -0800 (PST)
X-Received: by 2002:a25:2a4f:: with SMTP id q76mr22484533ybq.141.1546228867330;
        Sun, 30 Dec 2018 20:01:07 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546228867; cv=none;
        d=google.com; s=arc-20160816;
        b=h3SJoGhGrfhF3D9CeqTbfp6nzzTE3wPyThURlGl5HCM5KsLtANk+gYKJK6fXFLW1Vb
         PyueWFPgXOVuzZPjXXiD09Qv+px4B/ot9AaXYl941D/8IV9tNaSX7o1HnEXP9s8NJGhw
         tAgLNEYe32bWRbzlS9ayoZOiL2F/u5LtdZY79H6Gfq1gjCzQdtrG/t8hOSUu90z2+8tn
         7jCXlR/2xlGytoF0XTqJJgoWYy7tDyJ1UwpqvoN2nrxbW8Xn8xuTYJvsgLhDoe540VbM
         Fzmh5knj57mj0dIocNEcBbCXV3+775SZJi1g2aJzOz9uvie1l1SVEvYvOFmUKxhGnP5Q
         Pt3g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=HucXhT1A5BsfCWwXDCGEmDntqGT95qD9mv34uGfHnxM=;
        b=ByREbSwzR4HcZwmg8aw5gxiTPZsMq8G0oT2CPxaS6uw1a8UTKL+McXqP8OjP251gDi
         oNXaqtONbUsb+fDDMRHbIhy+t3aMqKtJynEIQ/apcBLz4Bvhf+CLQ9sx/ST1kbh5tu4t
         6QdunQUO9eCaIpM6NTveoKKKGz8Poo8OgjkG0hzCuooFHwON2KCf0t3WRp0/+TUU7zlc
         mtnBwF3iNOUJ+tIXNjX62JrbPC2IOZlcs6Q/nadG2pImrHXjO/zuzNMK6JZBLDYIUYKl
         P8odrQtXDsL2SJ2pvqbkQaO5XaiMXuJKT2vckEYKiBwmfkJCiDlNepOeOCpc8WmVD7nu
         IIrg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=RsuU+lvf;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s187sor6436246ywd.157.2018.12.30.20.01.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 30 Dec 2018 20:01:07 -0800 (PST)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=RsuU+lvf;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=HucXhT1A5BsfCWwXDCGEmDntqGT95qD9mv34uGfHnxM=;
        b=RsuU+lvfvuTkfqdJFBT8SLdXXznzlurD/F+aInXrpFa6GSP1fSjyw9q2m3Bau5zyDI
         dbelbjh6tB6WNln9v0wEi7oYQ2qGhxKwygG0+EFT8hgVL9owteRvqjBDDIT+R80Hb5p7
         f91auxNDqrYHTqNyZdIno7sRFtGHqqvz2oqegQzfBlu+vAmNZ6IC647YOAwvgKDwimpo
         doJ7peKGizkv0XNrw6XE8DceI4Ucv6f5HjratekTiSaqsBXVe4S2Uf1iiermj/g3ZZFw
         tLmWb2exvIfMvyST/43xDhptQM90g8BqL+tHxDbTVJnT5QfAZPmj3D+oBkS9vdj80q7V
         33bA==
X-Google-Smtp-Source: AFSGD/V4nZq7heg6xHqPmwYJmQWtTikncqxw/sJsQ9YY0Tk7m/QSKoI79X8QoNjMi43UVqebUtvkeLXv4lVFn3OObvs=
X-Received: by 2002:a81:7cd:: with SMTP id 196mr35500985ywh.255.1546228866798;
 Sun, 30 Dec 2018 20:01:06 -0800 (PST)
MIME-Version: 1.0
References: <20181229015524.222741-1-shakeelb@google.com> <20181229073325.GZ16738@dhcp22.suse.cz>
 <20181229095215.nbcijqacw5b6aho7@breakpoint.cc> <20181229100615.GB16738@dhcp22.suse.cz>
 <CALvZod7v-CC1XipLAerFj1Zp_M=qXZq6MzDL4pubJMTRCsMFNw@mail.gmail.com> <20181230074513.GA22445@dhcp22.suse.cz>
In-Reply-To: <20181230074513.GA22445@dhcp22.suse.cz>
From: Shakeel Butt <shakeelb@google.com>
Date: Sun, 30 Dec 2018 20:00:55 -0800
Message-ID:
 <CALvZod7sCXxVXwfvsR3jR8apq1BVFwv1sOinrgUfW+H5K3RJww@mail.gmail.com>
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
Message-ID: <20181231040055.HtXrl8dFnNbSRd3wJNUG5_dI3ydRQbqI1Ni3zN77iik@z>

On Sat, Dec 29, 2018 at 11:45 PM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Sat 29-12-18 11:34:29, Shakeel Butt wrote:
> > On Sat, Dec 29, 2018 at 2:06 AM Michal Hocko <mhocko@kernel.org> wrote:
> > >
> > > On Sat 29-12-18 10:52:15, Florian Westphal wrote:
> > > > Michal Hocko <mhocko@kernel.org> wrote:
> > > > > On Fri 28-12-18 17:55:24, Shakeel Butt wrote:
> > > > > > The [ip,ip6,arp]_tables use x_tables_info internally and the underlying
> > > > > > memory is already accounted to kmemcg. Do the same for ebtables. The
> > > > > > syzbot, by using setsockopt(EBT_SO_SET_ENTRIES), was able to OOM the
> > > > > > whole system from a restricted memcg, a potential DoS.
> > > > >
> > > > > What is the lifetime of these objects? Are they bound to any process?
> > > >
> > > > No, they are not.
> > > > They are free'd only when userspace requests it or the netns is
> > > > destroyed.
> > >
> > > Then this is problematic, because the oom killer is not able to
> > > guarantee the hard limit and so the excessive memory consumption cannot
> > > be really contained. As a result the memcg will be basically useless
> > > until somebody tears down the charged objects by other means. The memcg
> > > oom killer will surely kill all the existing tasks in the cgroup and
> > > this could somehow reduce the problem. Maybe this is sufficient for
> > > some usecases but that should be properly analyzed and described in the
> > > changelog.
> > >
> >
> > Can you explain why you think the memcg hard limit will not be
> > enforced? From what I understand, the memcg oom-killer will kill the
> > allocating processes as you have mentioned. We do force charging for
> > very limited conditions but here the memcg oom-killer will take care
> > of
>
> I was talking about the force charge part. Depending on a specific
> allocation and its life time this can gradually get us over hard limit
> without any bound theoretically.
>
> > Anyways, the kernel is already charging the memory for
> > [ip,ip6,arp]_tables and this patch adds the charging for ebtables.
> > Without this patch, as Kirill has described and shown by syzbot, a low
> > priority memcg can force system OOM.
>
> I am not opposing the patch per-se. I would just like the changelog to
> be more descriptive about the life time and consequences.
> --

I will resend the patch with more detailed change log.

thanks,
Shakeel


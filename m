Return-Path: <SRS0=Z+ZU=Q2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,FROM_EXCESS_BASE64,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 72B5CC43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 10:46:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2E42D21773
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 10:46:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="YpoYatti"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2E42D21773
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B91588E0004; Tue, 19 Feb 2019 05:46:06 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B42E58E0002; Tue, 19 Feb 2019 05:46:06 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A56B88E0004; Tue, 19 Feb 2019 05:46:06 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f72.google.com (mail-lf1-f72.google.com [209.85.167.72])
	by kanga.kvack.org (Postfix) with ESMTP id 35CB38E0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2019 05:46:06 -0500 (EST)
Received: by mail-lf1-f72.google.com with SMTP id c5so2212644lfi.7
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 02:46:06 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=ffG50zcYRZxWfUGn5WkhVM3jBYqv2vEwRvPWaUtideQ=;
        b=M1XRYCGCgzw5HHRe70gQSUN/cXkkhWnJBXdxdcgFn/RKSK9RzKyzFTafqFV4fmWWZz
         JJbN5FSXRC5lnuyb0a6m+k4Xg5Wqprcm21vMalh+PQ9sM0bPT3q1/ncx926wZ2a5Yq7J
         eS9TKvloq/nK3+CTIlG41PApSz6cKUGVQFwQ+/GCYlVqa7jsUE9hT1sz/HGpcGFdLjdn
         qe0+5z3u6/1Ifxrow4+D4NOx7itktRIIH+11giEzeqNIz/WqRRzlkIMGNnElDY/RHwQo
         dfE84mSDm6YSUbr9/8DCYcSIBerV4JLGc6OqkPxwkTDfvUrbptzitbJkm7qyoL4p2zua
         VKLg==
X-Gm-Message-State: AHQUAuZxUY25i/cMmqOXrjcdd7Q8zo+OEJWou36VNu0PQTZLFzuHu914
	grJmvmmQ6iKV+fU30kEMgiRJOFfO9G1KLitn6MsYmcJp3C5HC9b0ltP2oCbGPSn2I3Vuz9Tn1IE
	C60B6iBbXa1iLT246In3ltrxqF1C9K4DMLOlwRWYSYnXSwKDwMwipd6zwnisNTA+9gWLN8xS70A
	E5Kuwg6hrQhXhFL4nva3uVPGEw8PAiDB3Z0IkJ1QSzUGDaCKuAh67M6627Ge/7IwjL6lyZunTHC
	Dbvt4+n2unAkNd1xkZfQKsACQHUiS64IEPD95PArVNg1VxbKmGz850+K0vJyXGtRx2fMWZnA7qT
	tat3CTntl3yYtF9L86OR/qr2BunkPeDG0N2z55w0T/+LeDhwtROrp8I1uRBFVXnFuaXX162x7RF
	t
X-Received: by 2002:a19:260e:: with SMTP id m14mr17359274lfm.158.1550573165193;
        Tue, 19 Feb 2019 02:46:05 -0800 (PST)
X-Received: by 2002:a19:260e:: with SMTP id m14mr17359208lfm.158.1550573164070;
        Tue, 19 Feb 2019 02:46:04 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550573164; cv=none;
        d=google.com; s=arc-20160816;
        b=jyTwWlaUzEGlVuUAorYD6o1K5aU1K+jYgaH80TpiiT/BWGgr7Uw2/4Z4RmR0okN8//
         Rnza8Zay5x8+NyYX3sIL5PsrQRK/EudOS4/Zkgcu6185XxMtudJ4cWsDfhH1xLQipBB6
         hbJpM+kYiIffILXXCJ/vecix6I2MupG7X6goB6IS0ehn8CBzf4CKMs5VOC5DJ/vJc62P
         SkDFN5Kcf06J7IO1WxblbBOFhaiqV4P9iJ7rVegnsGQIbrkbx0p3yIkywqJ4Gvz8hqiO
         k7d/t+UaZeG9eX0fvShS+gRrraF8yHQ1SHOhxK7tLevVgiNN8uQrqSkTbnoOYLlWxh0b
         9hwA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=ffG50zcYRZxWfUGn5WkhVM3jBYqv2vEwRvPWaUtideQ=;
        b=gm5JGeI18YboD1k689oWgxb/B/afgXmAhv7CpxB62bg5tXe6iR5WpE8+KyhtzVawqb
         s2RIcS/XLbVcmmwjCbByj9eZjmlI240dBjJBwW6leqeW5Dn32NSKBwrgcAn/B2EBTfFU
         Mkt0Ae7al5H7YvBwAsH/Cp8CkBSrxZAdtc0C/x6NGbkwzBdMC4OjpzgZnyT91oi6cK3D
         6RPdna7Lknokr2LyxnOl7cLB+A5Nw1kvrJENMNiJGoATZ6WHppU0Tt7JxtgJOPc2693p
         57D7ggCbUtIIdLktOOOKHPnSxqQ9jwcQZjE2bjzIB94cDDnz7UQ0Xn8Ha6LoNNnntJ+x
         pVjg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=YpoYatti;
       spf=pass (google.com: domain of ufo19890607@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=ufo19890607@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q8-v6sor9327054ljg.29.2019.02.19.02.46.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Feb 2019 02:46:04 -0800 (PST)
Received-SPF: pass (google.com: domain of ufo19890607@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=YpoYatti;
       spf=pass (google.com: domain of ufo19890607@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=ufo19890607@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=ffG50zcYRZxWfUGn5WkhVM3jBYqv2vEwRvPWaUtideQ=;
        b=YpoYattijyPWHezIgZMKDwdjebSn69PKDuhJxtXkwpjt/p8HH2X1x+3YGadInP2Dx1
         rGlMK8oPorD/BJVjvzjPYOn/gp6hSvmVGAZ956FJHnKdzavF59LNoVdN9YDgc/JBqRM/
         DMoBFHlW/537VF0CeNabpK9+6W2AJ8K4ziSdeZh7zDDz34Oj9HlH7hYsMJzwv5j8UTKF
         /3gTZkXUKflREJJyEeTWV2M6GWGI/Tu8iuRyL3QeSNPeVcOHvR0lDn28auo4wrHXAkc4
         BFFliD+xepgc6tV+e4S7WKF07D5iNbCZwn3KyN38V83wZKBoOPwgJ6KE42M8l09V7GU2
         d6Pg==
X-Google-Smtp-Source: AHgI3IZ+FYcQpqLOs3r6vs6rfw+yWXTt3gr7z2oiY8vq1ixrrl1/gx3aW8UGINQJJL3tc1uFpnVxZoP13f0D7A/hf1Y=
X-Received: by 2002:a2e:965a:: with SMTP id z26mr15089257ljh.59.1550573163554;
 Tue, 19 Feb 2019 02:46:03 -0800 (PST)
MIME-Version: 1.0
References: <1550278564-81540-1-git-send-email-yang.shi@linux.alibaba.com> <20190218210504.GT50184@devbig004.ftw2.facebook.com>
In-Reply-To: <20190218210504.GT50184@devbig004.ftw2.facebook.com>
From: =?UTF-8?B?56a56Iif6ZSu?= <ufo19890607@gmail.com>
Date: Tue, 19 Feb 2019 18:45:52 +0800
Message-ID: <CAHCio2g-S6snHsh84r0Wp1RQW1CR3t_eyUUjcdDaxnUHWTcdFw@mail.gmail.com>
Subject: Re: [PATCH] doc: cgroup: correct the wrong information about measure
 of memory pressure
To: Tejun Heo <tj@kernel.org>
Cc: Yang Shi <yang.shi@linux.alibaba.com>, hannes@cmpxchg.org, corbet@lwn.net, 
	cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi TeJun
I've built the 5.0.0-rc6 kernel with psi option, but I cannot find any
cgroup.controllers when I mounted cgroup2.

[root@bogon /]# uname -r
[root@bogon /]# 5.0.0-rc6+
[root@bogon /]# mount -t cgroup2 none cgroup2/
[root@bogon /]# cat cgroup2/cgroup.controllers
[root@bogon /]
[root@bogon /]# cat cgroup2/cgroup.subtree_control
[root@bogon /]#

What's wrong with this kernel? Or maybe I lost some mount option?

Thanks
Yuzhoujian

Tejun Heo <tj@kernel.org> =E4=BA=8E2019=E5=B9=B42=E6=9C=8819=E6=97=A5=E5=91=
=A8=E4=BA=8C =E4=B8=8A=E5=8D=8810:32=E5=86=99=E9=81=93=EF=BC=9A
>
> On Sat, Feb 16, 2019 at 08:56:04AM +0800, Yang Shi wrote:
> > Since PSI has implemented some kind of measure of memory pressure, the
> > statement about lack of such measure is not true anymore.
> >
> > Cc: Tejun Heo <tj@kernel.org>
> > Cc: Johannes Weiner <hannes@cmpxchg.org>
> > Cc: Jonathan Corbet <corbet@lwn.net>
> > Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
> > ---
> >  Documentation/admin-guide/cgroup-v2.rst | 3 +--
> >  1 file changed, 1 insertion(+), 2 deletions(-)
> >
> > diff --git a/Documentation/admin-guide/cgroup-v2.rst b/Documentation/ad=
min-guide/cgroup-v2.rst
> > index 7bf3f12..9a92013 100644
> > --- a/Documentation/admin-guide/cgroup-v2.rst
> > +++ b/Documentation/admin-guide/cgroup-v2.rst
> > @@ -1310,8 +1310,7 @@ network to a file can use all available memory bu=
t can also operate as
> >  performant with a small amount of memory.  A measure of memory
> >  pressure - how much the workload is being impacted due to lack of
> >  memory - is necessary to determine whether a workload needs more
> > -memory; unfortunately, memory pressure monitoring mechanism isn't
> > -implemented yet.
> > +memory.
>
> Maybe refer to PSI?
>
> Thanks.
>
> --
> tejun


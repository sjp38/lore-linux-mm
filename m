Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,HTML_MESSAGE,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 214D6C04AB5
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 15:03:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CBDC92083D
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 15:03:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="SszZ9ZwC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CBDC92083D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4C6F76B027B; Thu,  6 Jun 2019 11:03:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 477266B027C; Thu,  6 Jun 2019 11:03:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 33F126B027D; Thu,  6 Jun 2019 11:03:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1490C6B027B
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 11:03:51 -0400 (EDT)
Received: by mail-it1-f199.google.com with SMTP id o128so203463ita.0
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 08:03:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=3bUQ36whl76VmAdo6KtQg0fChgn8q95Jwy2iC4IHnQU=;
        b=Uy9GB2WclUfTU/dsLSstiDUTieTPD9vTq1tWb32ZpSl3E0k3u4Vxl4H84c+Cn5lGx6
         SCBuYGml/V9+E+SJj15CBkxJWvXJz32KUEMBB+Uq4RMjmbho/ltYBPhGCL7ABK8kXSgI
         7y88mzxaQEL35LEGnhfQ+5UOpwZ8DptwldpuiebiDkFDde4GobiYgUNDP+NyRekCMAPN
         iTB/IT6J2fS/ZjuZQNza5s1Kdud0vQotKcabRI3alXYmKMnaqgMzbkU4LaSiZE9aIXB9
         KxDpSgH7qVC2Y8Hhr0ZHPCwUqpAVGhNAt6odUG240wOyyqYr4fiegnl+IV4YzuijZP8P
         7fug==
X-Gm-Message-State: APjAAAUl/Cpj+WM4vPMqeRFqQ6SX1YN91ecoh2eTG8tOycmIHc1uBPqP
	uLMaVq7xHdJ9WNIP9bPCv4daKE96jD2x9Fj2KErSOUaYQCwT1g4bAFc0U/LIfOvfKnOKUFXsHfK
	HGntNGP5gQxthj5tNP/X4j6hCvNIgsssxNzqCIJIB6sdCLUEtmQrPQzNX4i8Y7sAX1w==
X-Received: by 2002:a02:5488:: with SMTP id t130mr32275940jaa.20.1559833430739;
        Thu, 06 Jun 2019 08:03:50 -0700 (PDT)
X-Received: by 2002:a02:5488:: with SMTP id t130mr32275888jaa.20.1559833430214;
        Thu, 06 Jun 2019 08:03:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559833430; cv=none;
        d=google.com; s=arc-20160816;
        b=f1UuWue/h/a6F9CykwbAIR+SGk0WZSrlPRZDq/sv+y04iqKSBvX1AIZoqmCXriB+m6
         0Aa/Q2KRWz3R58ATPjibkT7lXDz75Zs15LZCoS3lMFT4s9iWdnt7P6TQneegho6WeHMH
         OK78R4/3khSDqwyUY2Gx4fdiudhXcaXwWKQwe3iwhTkqbIh36aVfQIGNAgfmQQf8azLz
         WgT6vCvwlUDV2+8W1uj7W+XnEBhQGsOPfYhlooSwWG3n8Zoiiv7+Ni/QM90Ih+gz7e0I
         RpuYXIaa+brTgOb3/XM6JsAjO5CQtjhpBTkpf76nWvFKaUtZANr/HWBGD2wz2orHP7Qn
         u2Eg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=3bUQ36whl76VmAdo6KtQg0fChgn8q95Jwy2iC4IHnQU=;
        b=lv2hSH8MVg8bIAdPRZ1DVq7IZxfrtBjelrNzpIquGA6YwJDkpkrQNWYe6s+CIFrt8e
         +mf7CXkiA/6OxWKGgin1j0mIKZWpRUed7Jv1GYwVdyFidVRcbqmt4S5Wz3n6QLLzzyVt
         kRNAJzesvHRL+4AoSjQ77EkERPe+HTs4C25uKFqIZmy5tbT8aah8rhN/mnKTjji+nPTV
         1jJCk1AyoO72U8V37Tx/YmLBxBauIQbzdWdn43pgKu4/Wu1XD/NbYs5fqE4V+xDHBLSe
         2/LDsGw+f8kji/51+Z/DzEK7hCfI1MUoUgLmGfEDrUuPV3xehUaFTzmQrynGClFqsd29
         KdPw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=SszZ9ZwC;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p18sor4676088jac.5.2019.06.06.08.03.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 06 Jun 2019 08:03:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=SszZ9ZwC;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=3bUQ36whl76VmAdo6KtQg0fChgn8q95Jwy2iC4IHnQU=;
        b=SszZ9ZwCUxtPao+UmqXPIkXMwWJf2U4LwrTUGgJYjmTw8md7Uwmph7hle8U9A33i5R
         EBV48cTnDJtNziErUgNBn1BZ+ucifhjZ8yB910C1od80Nix1B9hFlDAqNPZxVvBxBMYm
         JcHzCiErdAeT7nPmX9vl6KCJktaDYP/Q3k25CYV5YmKvzNMbiXYLYgCVtFy6v9Lz1PCB
         0UpEBmw1lifNGC3rVxDw23rrfzIrkFa8ErbEVt4ipTyWusi5f5f7WpR86p3Holtr9u74
         0sykbvSpdfutoShOwIjvhb4D2UT9xLcKfKDlCBpS4iKNI4S0qvj5Qj5R4QZyzOLSfP4X
         uMCA==
X-Google-Smtp-Source: APXvYqz8so4t6R0hY8BM+ptsKVjOAgxxnUD7fn2GYcLvINP5Rrx5vBsW5FNfviem0hxOOOtS6NqzWVpej4cP4w04t+g=
X-Received: by 2002:a02:c519:: with SMTP id s25mr29651011jam.11.1559833429925;
 Thu, 06 Jun 2019 08:03:49 -0700 (PDT)
MIME-Version: 1.0
References: <1559816080-26405-1-git-send-email-laoar.shao@gmail.com>
 <20190606111755.GB15779@dhcp22.suse.cz> <CALOAHbDYKL2kSfaf9Z_E=TyNQtGaAUfxG8MkSXb1g0VSkcYzNA@mail.gmail.com>
 <20190606144439.GA12311@dhcp22.suse.cz>
In-Reply-To: <20190606144439.GA12311@dhcp22.suse.cz>
From: Yafang Shao <laoar.shao@gmail.com>
Date: Thu, 6 Jun 2019 23:03:12 +0800
Message-ID: <CALOAHbBuF07j1Nt2tAg6Hd2ucse6O9PLhY-yr_K-56zerst=iQ@mail.gmail.com>
Subject: Re: [PATCH v4 0/3] mm: improvements in shrink slab
To: Michal Hocko <mhocko@suse.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Bharath Vedartham <linux.bhar@gmail.com>, 
	Linux MM <linux-mm@kvack.org>, shaoyafang@didiglobal.com
Content-Type: multipart/alternative; boundary="0000000000007fe381058aa905b4"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--0000000000007fe381058aa905b4
Content-Type: text/plain; charset="UTF-8"

On Thu, Jun 6, 2019 at 10:44 PM Michal Hocko <mhocko@suse.com> wrote:

> On Thu 06-06-19 22:18:41, Yafang Shao wrote:
> [...]
> > Well, seems when we introduce new feature for page relciam, we always
> > ignore the node reclaim path.
>
> Yes, node reclaim is quite weird and I am not really sure whether we
> still have many users these days. It used to be mostly driven by
> artificial benchmarks which highly benefit from the local node access.
> We have turned off its automatic enabling when there are nodes with
> higher access latency quite some time ago without anybody noticing
> actually.
>
> > Regarding node reclaim path, we always turn it off on our servers,
> > because we really found some latency spike caused by node reclaim
> > (the reason why node reclaim is turned on is not clear).
>
> Yes, that was the case and the reason it is not enabled by default.
>
> > The reason I expose node reclaim details to userspace is because the user
> > can set node reclaim details now.
>
> Well, just because somebody _can_ enable it doesn't sound like a
> sufficient justification to expose even more implementation details of
> this feature. I am not really sure there is a strong reason to touch the
> code without a real usecase behind.
>
>
Got it.

So should we fix the bugs in node reclaim path then?

Thanks
Yafang

--0000000000007fe381058aa905b4
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div dir=3D"ltr"><br></div><br><div class=3D"gmail_quote">=
<div dir=3D"ltr" class=3D"gmail_attr">On Thu, Jun 6, 2019 at 10:44 PM Micha=
l Hocko &lt;<a href=3D"mailto:mhocko@suse.com">mhocko@suse.com</a>&gt; wrot=
e:<br></div><blockquote class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0=
.8ex;border-left:1px solid rgb(204,204,204);padding-left:1ex">On Thu 06-06-=
19 22:18:41, Yafang Shao wrote:<br>
[...]<br>
&gt; Well, seems when we introduce new feature for page relciam, we always<=
br>
&gt; ignore the node reclaim path.<br>
<br>
Yes, node reclaim is quite weird and I am not really sure whether we<br>
still have many users these days. It used to be mostly driven by<br>
artificial benchmarks which highly benefit from the local node access.<br>
We have turned off its automatic enabling when there are nodes with<br>
higher access latency quite some time ago without anybody noticing<br>
actually.<br>
<br>
&gt; Regarding node reclaim path, we always turn it off on our servers,<br>
&gt; because we really found some latency spike caused by node reclaim<br>
&gt; (the reason why node reclaim is turned on is not clear).<br>
<br>
Yes, that was the case and the reason it is not enabled by default.<br>
<br>
&gt; The reason I expose node reclaim details to userspace is because the u=
ser<br>
&gt; can set node reclaim details now.<br>
<br>
Well, just because somebody _can_ enable it doesn&#39;t sound like a<br>
sufficient justification to expose even more implementation details of<br>
this feature. I am not really sure there is a strong reason to touch the<br=
>
code without a real usecase behind.<br>
<br></blockquote><div><br></div><div>Got it.</div><div><br></div><div>So sh=
ould we fix the bugs in node reclaim path then?</div><div><br></div><div>Th=
anks</div><div>Yafang=C2=A0</div></div></div>

--0000000000007fe381058aa905b4--


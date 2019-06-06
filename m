Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,HTML_MESSAGE,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 051A2C04AB5
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 14:19:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B19A120665
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 14:19:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Ig9ifMmm"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B19A120665
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3D6706B0278; Thu,  6 Jun 2019 10:19:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3861E6B0279; Thu,  6 Jun 2019 10:19:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 275326B027A; Thu,  6 Jun 2019 10:19:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id 06F586B0278
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 10:19:19 -0400 (EDT)
Received: by mail-it1-f197.google.com with SMTP id s2so58267itl.7
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 07:19:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=oQUBF0jy1OvkA2jcVdUfqiZcWMBVb+S1QF5C4Cc+e28=;
        b=jV80jEHXmrdBH24tqDYnO3Q1kFGBwW4VlQZXsG3O7eriqnUzgSfL6cjiN/BgwHj8iR
         JUFnKM50njYIpa8OXBo8wqIjGhds17HtS4hHKlsvVSRtVAWBxP016TfAo+JD2SeepkDx
         uYSONlnufrU/opnuRzdnpc8hd31XSWGN7jLu/DRsx6UB6SYext+4k5CR4IXlgsHWClwS
         4pwrLBZ6YZl1YIakCVyB3t4FWf/t5BJ48Ixx/udUWz9OB8ugrgnNY3SPfAg5g5Ch6Ymj
         eKjW0kYGqfWq5xt0LvO24ArKwmwtzdY4ckt80kdncQwoqJhgsrl5vlTIEysNOVlWIedU
         HTow==
X-Gm-Message-State: APjAAAV+O3B5rtJ0vnEIg/E1eUQv62pPkqH//Sj2PK0O1wU2lF7RCIV+
	8RlR1wE7vAr3Zm2RClKbXXWDfTSQZOJOJwl0o6IdYjxPQOffUXulC9fXmG1QwOUbvsRxL6HTJqB
	ynjtX7lJMt6fyja7p9vpYWAFN8Sqaz9IWXWqQo/KWEECt+9HZgHp0xCgBcv6SHjUaYg==
X-Received: by 2002:a02:1948:: with SMTP id b69mr8690982jab.55.1559830758776;
        Thu, 06 Jun 2019 07:19:18 -0700 (PDT)
X-Received: by 2002:a02:1948:: with SMTP id b69mr8690929jab.55.1559830758215;
        Thu, 06 Jun 2019 07:19:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559830758; cv=none;
        d=google.com; s=arc-20160816;
        b=HYwJYSrOWS7aBp5RoYzksjaqzsWLgl9KklkyxdK1iLLnn2URaAFGniL7rCv6uHwvkr
         W65z4nR7TIFsDWt38MUmsWHMrHjMOWhq30UxqNJ/Vs9k9085n5wrh6hMJyuncVqLPnbi
         yZGnaiU54h2jnhMCTshVPToGeIhVBt4jnNp30WNKr6RFsx0+7IxcoGsL0srjmXBAUe23
         g419ycVqySmSeegTzH2Hoiu1FSictVnbF1rGpSZEcJ2v/BxukTmpU17JdNZO2mYPGQ+8
         LNlqCVimIiPqjgCAXewGejhFz3D7LODxXsORqdJIqw7+zCWf3NTfDtrTfr3w8G5CLpLt
         3zBg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=oQUBF0jy1OvkA2jcVdUfqiZcWMBVb+S1QF5C4Cc+e28=;
        b=Q3/1wquQRmWo0Z3x+1OAfhfxNIogfV7ao1dUQ7nKdRKNVukE3NtCy/eNOxdGwOOSuB
         qD+7LXnzKnquB/zAarDHkCjPWbtBrCJXpTjBdpEEMrUSqo2VJkT757a/hi5NGVMb7diN
         dDWopm3pjSJgMojceTrCBgbFSO8n5SbTA0H16ars9UvuQYYkZDr5uuRMaDVjdfj5MeB6
         wCNBtW0Gxe/kGij+Xe02vNfiBDHoNuIkWBwBTw/tSaWZR/pPIuOt8MUds92VZe2LQfHq
         xo4l481sTnWR2nA85gmjMFZM0EkBFnuuv+8zWbZgCJxNewO/pnZt65aH2KyKz1y6j1I4
         QiKQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Ig9ifMmm;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k21sor2890047itk.7.2019.06.06.07.19.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 06 Jun 2019 07:19:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Ig9ifMmm;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=oQUBF0jy1OvkA2jcVdUfqiZcWMBVb+S1QF5C4Cc+e28=;
        b=Ig9ifMmmtZkc9IMJ0ixYy2avwEdTu0TLLj1xTTmgEahp+25uKMtxuIPYkRnR2Yiufm
         9AMGw/RMAN2+SeiqFl4HxXLKR1c+kqIaoUtSuVyiP1HEFcq+LTGB0Su77VEpH6xzCFuj
         BO2dsJy6NT43jAkhRKGnwFOY5UdVDJ6OlHlacUlS1sTXSHNhT2WW4cmLmM2rKFJ/L2I/
         SlGe1sRYbfoVWt2uyOVjr0+16oR5hjRhmyFjYPMFu5UZO7VMrRNCYIyPSEo+JsEu3L6J
         xCrzyjYTcxsTmWzco5HeqOw71MbQd7vivdLvCtRUPKYr35VYghtPcgBjmo0nKxekFTD5
         c61Q==
X-Google-Smtp-Source: APXvYqzjo+hHdnQg+1oPErVLdRrzdgTP8IHy3oD3Qpn8SyVzMaXWbgLUI/CoN7OdkHlz/bo6w63sKgNrau8NLjzwDOo=
X-Received: by 2002:a24:dac7:: with SMTP id z190mr190737itg.57.1559830757840;
 Thu, 06 Jun 2019 07:19:17 -0700 (PDT)
MIME-Version: 1.0
References: <1559816080-26405-1-git-send-email-laoar.shao@gmail.com> <20190606111755.GB15779@dhcp22.suse.cz>
In-Reply-To: <20190606111755.GB15779@dhcp22.suse.cz>
From: Yafang Shao <laoar.shao@gmail.com>
Date: Thu, 6 Jun 2019 22:18:41 +0800
Message-ID: <CALOAHbDYKL2kSfaf9Z_E=TyNQtGaAUfxG8MkSXb1g0VSkcYzNA@mail.gmail.com>
Subject: Re: [PATCH v4 0/3] mm: improvements in shrink slab
To: Michal Hocko <mhocko@suse.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Bharath Vedartham <linux.bhar@gmail.com>, 
	Linux MM <linux-mm@kvack.org>, shaoyafang@didiglobal.com
Content-Type: multipart/alternative; boundary="0000000000003b1ced058aa8664d"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--0000000000003b1ced058aa8664d
Content-Type: text/plain; charset="UTF-8"

On Thu, Jun 6, 2019 at 7:17 PM Michal Hocko <mhocko@suse.com> wrote:

> On Thu 06-06-19 18:14:37, Yafang Shao wrote:
> > In the past few days, I found an issue in shrink slab.
> > We I was trying to fix it, I find there are something in shrink slab need
> > to be improved.
> >
> > - #1 is to expose the min_slab_pages to help us analyze shrink slab.
> >
> > - #2 is an code improvement.
> >
> > - #3 is a fix to a issue. This issue is very easy to produce.
> > In the zone reclaim mode.
> > First you continuously cat a random non-exist file to produce
> > more and more dentry, then you read big file to produce page cache.
> > Finally you will find that the denty will never be shrunk.
> > In order to fix this issue, a new bitmask no_pagecache is introduce,
> > which is 0 by defalt.
>
> Node reclaim mode is quite special and rarely used these days. Could you
> be more specific on how did you get to see the above problems? Do you
> really need node reclaim in your usecases or is this more about a
> testing and seeing what happens. Not that I am against these changes but
> I would like to understand the motivation. Especially because you are
> exposing some internal implementation details of the node reclaim to the
> userspace.
>
>
The slab issue we found on our server is on old kernel (kernel-3.10).
We found that the dentry was continuesly growing without shrinking in one
container on a server,
so I read slab code and found that memcg relcaim can't shrink slab in this
old kenrel,
but this issue was aready fixed in upstream.

When I was reading the shrink slab code in the upstream kernel,
I found the slab can't be shrinked in node reclaim.
So I did some test to produce this issue and post this patchset to fix it.
With my patch, the issue produced by me disapears.

But this is only a beginning in the node reclaim path...
Then I found another issue when I implemented a memory pressure monitor for
out containers,
which is vmpressure_prio() is missed in the node reclaim path.

Well, seems when we introduce new feature for page relciam, we always
ignore the node reclaim path.

Regarding node reclaim path, we always turn it off on our servers,
because we really found some latency spike caused by node reclaim
(the reason why node reclaim is turned on is not clear).

The reason I expose node reclaim details to userspace is because the user
can set node reclaim details now.

Thanks
Yafang

--0000000000003b1ced058aa8664d
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><br><br><div class=3D"gmail_quote"><div dir=3D"ltr" class=
=3D"gmail_attr">On Thu, Jun 6, 2019 at 7:17 PM Michal Hocko &lt;<a href=3D"=
mailto:mhocko@suse.com">mhocko@suse.com</a>&gt; wrote:<br></div><blockquote=
 class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;border-left:1px so=
lid rgb(204,204,204);padding-left:1ex">On Thu 06-06-19 18:14:37, Yafang Sha=
o wrote:<br>
&gt; In the past few days, I found an issue in shrink slab.<br>
&gt; We I was trying to fix it, I find there are something in shrink slab n=
eed<br>
&gt; to be improved.<br>
&gt; <br>
&gt; - #1 is to expose the min_slab_pages to help us analyze shrink slab.<b=
r>
&gt; <br>
&gt; - #2 is an code improvement.<br>
&gt; <br>
&gt; - #3 is a fix to a issue. This issue is very easy to produce.<br>
&gt; In the zone reclaim mode.<br>
&gt; First you continuously cat a random non-exist file to produce<br>
&gt; more and more dentry, then you read big file to produce page cache.<br=
>
&gt; Finally you will find that the denty will never be shrunk.<br>
&gt; In order to fix this issue, a new bitmask no_pagecache is introduce,<b=
r>
&gt; which is 0 by defalt.<br>
<br>
Node reclaim mode is quite special and rarely used these days. Could you<br=
>
be more specific on how did you get to see the above problems? Do you<br>
really need node reclaim in your usecases or is this more about a<br>
testing and seeing what happens. Not that I am against these changes but<br=
>
I would like to understand the motivation. Especially because you are<br>
exposing some internal implementation details of the node reclaim to the<br=
>
userspace.<br><br></blockquote><div><br></div><div>The slab issue we found =
on our server is on old kernel (kernel-3.10).</div><div>We found that the d=
entry was continuesly growing without shrinking in one container on a serve=
r,</div><div>so I read slab code and found that memcg relcaim can&#39;t shr=
ink slab in this old kenrel,=C2=A0</div><div>but this issue was aready fixe=
d in upstream.</div><div><br></div><div>When I was reading the shrink slab =
code in the upstream kernel,</div><div>I found the slab can&#39;t be shrink=
ed in node reclaim.</div><div>So I did some test to produce this issue and =
post this patchset to fix it.</div><div>With my patch, the issue produced b=
y me disapears.=C2=A0</div><div><br></div><div>But this is only a beginning=
 in the node reclaim path...</div><div>Then I found another issue when I im=
plemented a memory pressure monitor for out containers,</div><div>which is =
vmpressure_prio() is missed in the node reclaim path.</div><div><br></div><=
div>Well, seems when we introduce new feature for page relciam, we always i=
gnore the node reclaim path.</div><div><br></div><div>Regarding node reclai=
m path, we always turn it off on our servers,</div><div>because we really f=
ound some latency spike caused by node reclaim</div><div>(the reason why no=
de reclaim is turned on is not clear).</div><div><br></div><div>The reason =
I expose node reclaim details to userspace is because the user can set node=
 reclaim details now.</div><div><br></div><div>Thanks</div><div>Yafang</div=
></div></div>

--0000000000003b1ced058aa8664d--


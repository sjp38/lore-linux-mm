Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,HTML_MESSAGE,
	MAILING_LIST_MULTI,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E6DB0C43219
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 22:41:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CBED72067C
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 22:41:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="T5UaL/qa"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CBED72067C
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DDBAE6B0005; Thu, 25 Apr 2019 18:41:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D64576B0006; Thu, 25 Apr 2019 18:41:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C08D26B0007; Thu, 25 Apr 2019 18:41:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f198.google.com (mail-vk1-f198.google.com [209.85.221.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9E9AA6B0005
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 18:41:01 -0400 (EDT)
Received: by mail-vk1-f198.google.com with SMTP id k78so620023vkk.17
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 15:41:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=RhtWDbws+hNR1IIrdpYk0qDPZv9M76fS/kkDU4hipnM=;
        b=F2Ga6+Tec+nmeI12rSAOSpHB0K/JgRldATcgngnLwAe+wNUppRSaNjxSU56crYWa8Q
         M60k5yrKMhMqIitXJSZOw4ZmbXyP/rebezJL6Qt7+bVQY+E5fGVKEvSunWkcZHGPnYsx
         DolBmleX73vf/lqvjB0ZQwhEAiRra8ZIqZ3874uAnswci+dmWdVe1op5FvfYWekK2vqh
         NP27cv+L2PawleKoc/0T2rE6E2c60t28pbrRygDKCbXKDzSEYCBy0WXPzlB8v6LuuRHF
         wskvqJ8f9HdSUqFEHBNY7rh0jUj6fTvPez0Z6XysEGw1GjtnMyhWG0x+iCVjWW7ijvsT
         NFdg==
X-Gm-Message-State: APjAAAWBGb4lHeQE3e2DphIImf2dGGKlYhtt9KJt/ydqhgwxa+WEF6/z
	hq6kTUS/j6WlDzIRe/7ckrd7UN/I9IB6yE40AtOQRtgeltLorBbfJfauZ7QfkBnTQyRWLsAjtfE
	g86+L+kC0wkKbkSgtDaYn3swzRjJdO1Jk0I8eot0p9tXJAwEgA5cdWeS7N1TjF8K8vQ==
X-Received: by 2002:ab0:49ea:: with SMTP id f39mr10500222uad.39.1556232061369;
        Thu, 25 Apr 2019 15:41:01 -0700 (PDT)
X-Received: by 2002:ab0:49ea:: with SMTP id f39mr10500199uad.39.1556232060785;
        Thu, 25 Apr 2019 15:41:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556232060; cv=none;
        d=google.com; s=arc-20160816;
        b=WdUzOtWWFJsCN+UEgmMeu44hBnGHJCEJuKq0BKc2Ff0/wJoF28UUoQ452/xUhdgm4r
         DnTOVVJdumLm1AWF0e++6M5W5wTvXYWpR73hssprc0JQomzt1EXy4tA9ZATC+THAowrV
         aVk1RkPQJT0aWQSL2ywfGEAvlrjUIKL14QFxSxTZKtyh0/tX59WonrMYZDjHw5GBDaeU
         XGM/tlfDDbPd4vTkyu6qqCeS8DL1FJJF3XMOdxkIEpzheJuuyEhLw5jI6nixE+yfqjGD
         0m4GYDlA9fSItES5FF+B9FU8PgOflt+1cij73Cl7nigecIN0r/vyp22yrzHms6VJADav
         /cTA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=RhtWDbws+hNR1IIrdpYk0qDPZv9M76fS/kkDU4hipnM=;
        b=uEWpsd25SiSGLejPXxwAUFU7VTchOfiyJz0iF2YKgsnR1aswa8mNnkizwZvWhxPy7F
         nNx+95da88TTj/pzz1b2GdunRJFIfIOuLFpVDRNCVqgPkMKOKH605WY/T2LB16JxshYq
         foFilV2HiD5Ac6dERurQdGReHnCPYIA0vLgpb8xIac/llpeAsCajBTuq60BGf26YVbwM
         yd1drT1b0lnut39lLe9cPZSe4WKALSWgGKCd1SIXgiwl2Ems4o2QIavbXDy5N78Bmxeb
         tD4uZkwMydoJMx9y1/uLGKGfv0BU0rUHItMwBR1LTtujqRwKlAivpDD6sU0mTerlCIUz
         zfog==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="T5UaL/qa";
       spf=pass (google.com: domain of pjt@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pjt@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t4sor8078542vkk.55.2019.04.25.15.41.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 25 Apr 2019 15:41:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of pjt@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="T5UaL/qa";
       spf=pass (google.com: domain of pjt@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pjt@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=RhtWDbws+hNR1IIrdpYk0qDPZv9M76fS/kkDU4hipnM=;
        b=T5UaL/qaUpYbJQfpTOvpd6rEjEcoHkK6Yl1HFY4l6BiKport0oikUsKKm3bzsaq6PS
         olM4L4+d7x6/G39ztmau0vEXS+8+WyQu7POirgppk9RVQBGJXvVgNrRC7T7kjIwlI3Qi
         yqm2vhDgR74XQlAgb1QkpjR1FPf8KjPNW22pR233ztAD4UIJjTU6zYK9iY/Q2J0YQXOb
         rqnUMmUT0R7YxlOtiQFXiFLBAQLOfVnx7EInlvhcvdRkozBJuth9r85mX0lPiY6gwU4H
         OAS0k2E6yxbEmjFV3v6ez9B1GKzHqo7RjsgDYpzc1e0dXFYLzR6GL/QCqyh9aho6WSsq
         yY5g==
X-Google-Smtp-Source: APXvYqzdaaF61c1CoXGNQakh5wq7P4TPSBxV5nVscBcWlUcho7YUZzA4kDmpoTJXOhNLFSbRY9z2eeKk/DvIaOXNGao=
X-Received: by 2002:a1f:4ec7:: with SMTP id c190mr21816686vkb.27.1556232060086;
 Thu, 25 Apr 2019 15:41:00 -0700 (PDT)
MIME-Version: 1.0
References: <20190207072421.GA9120@rapoport-lnx> <CA+VK+GOpjXQ2-CLZt6zrW6m-=WpWpvcrXGSJ-723tRDMeAeHmg@mail.gmail.com>
 <CAPM31RKpR0EZoeXZMXciTxvjBEeu3Jf3ks4Dn9gERxXghoB67w@mail.gmail.com>
 <CA+VK+GOOv4Vpfv+yMwHGwyf_a5tvcY9_0naGR=LgzxTFbDkBnQ@mail.gmail.com>
 <1556229406.24945.10.camel@HansenPartnership.com> <CAPM31R+Wd=2ZMJmg3dZ37xnzHrsnMP6CYZrV+evqNY4Vb6Paqw@mail.gmail.com>
 <CAADnVQLJqRm=TR7cY8XKYBo63LsJk=bqvn=es3v+2SBa_8zofg@mail.gmail.com>
In-Reply-To: <CAADnVQLJqRm=TR7cY8XKYBo63LsJk=bqvn=es3v+2SBa_8zofg@mail.gmail.com>
From: Paul Turner <pjt@google.com>
Date: Thu, 25 Apr 2019 15:40:23 -0700
Message-ID: <CAPM31R+NW1GhNRBVzeLCwxrMAmS3GJGUNo_CsXNuqpJsqn3Zvg@mail.gmail.com>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] Address space isolation inside the kernel
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Cc: James Bottomley <James.Bottomley@hansenpartnership.com>, linux-mm <linux-mm@kvack.org>, 
	lsf-pc@lists.linux-foundation.org, Mike Rapoport <rppt@linux.ibm.com>, 
	Jonathan Adams <jwadams@google.com>, Daniel Borkmann <daniel@iogearbox.net>, Jann Horn <jannh@google.com>
Content-Type: multipart/alternative; boundary="00000000000021d0ec05876283c7"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--00000000000021d0ec05876283c7
Content-Type: text/plain; charset="UTF-8"

On Thu, Apr 25, 2019 at 3:31 PM Alexei Starovoitov <
alexei.starovoitov@gmail.com> wrote:

> On Thu, Apr 25, 2019 at 3:27 PM Paul Turner via Lsf-pc
> <lsf-pc@lists.linux-foundation.org> wrote:
> >
> > On Thu, Apr 25, 2019 at 2:56 PM James Bottomley <
> > James.Bottomley@hansenpartnership.com> wrote:
> >
> > > On Thu, 2019-04-25 at 13:47 -0700, Jonathan Adams wrote:
> > > > It looks like the MM track isn't full, and I think this topic is an
> > > > important thing to discuss.
> > >
> > > Mike just posted the RFC patches for this using a ROP gadget preventor
> > > as a demo:
> > >
> > >
> > >
> https://lore.kernel.org/linux-mm/1556228754-12996-1-git-send-email-rppt@linux.ibm.com
> > >
> > > but, unfortunately, he won't be at LSF/MM.
> > >
> > > James
> > >
> >
> > Mike's proposal is quite different, and targeted at restricting ROP
> > execution.
> > The work proposed by Jonathan is aimed to transparently restrict
> > speculative execution to provide generic mitigation against Spectre-V1
> > gadgets (and similar) and potentially eliminate the current need for for
> > page table switches under most syscalls due to Meltdown.
>
> sounds very interesting.
> "v1 gadgets" would include unpriv bpf code too?
>

Yes

--00000000000021d0ec05876283c7
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div dir=3D"ltr"><br></div><br><div class=3D"gmail_quote">=
<div dir=3D"ltr" class=3D"gmail_attr">On Thu, Apr 25, 2019 at 3:31 PM Alexe=
i Starovoitov &lt;<a href=3D"mailto:alexei.starovoitov@gmail.com">alexei.st=
arovoitov@gmail.com</a>&gt; wrote:<br></div><blockquote class=3D"gmail_quot=
e" style=3D"margin:0px 0px 0px 0.8ex;border-left:1px solid rgb(204,204,204)=
;padding-left:1ex">On Thu, Apr 25, 2019 at 3:27 PM Paul Turner via Lsf-pc<b=
r>
&lt;<a href=3D"mailto:lsf-pc@lists.linux-foundation.org" target=3D"_blank">=
lsf-pc@lists.linux-foundation.org</a>&gt; wrote:<br>
&gt;<br>
&gt; On Thu, Apr 25, 2019 at 2:56 PM James Bottomley &lt;<br>
&gt; <a href=3D"mailto:James.Bottomley@hansenpartnership.com" target=3D"_bl=
ank">James.Bottomley@hansenpartnership.com</a>&gt; wrote:<br>
&gt;<br>
&gt; &gt; On Thu, 2019-04-25 at 13:47 -0700, Jonathan Adams wrote:<br>
&gt; &gt; &gt; It looks like the MM track isn&#39;t full, and I think this =
topic is an<br>
&gt; &gt; &gt; important thing to discuss.<br>
&gt; &gt;<br>
&gt; &gt; Mike just posted the RFC patches for this using a ROP gadget prev=
entor<br>
&gt; &gt; as a demo:<br>
&gt; &gt;<br>
&gt; &gt;<br>
&gt; &gt; <a href=3D"https://lore.kernel.org/linux-mm/1556228754-12996-1-gi=
t-send-email-rppt@linux.ibm.com" rel=3D"noreferrer" target=3D"_blank">https=
://lore.kernel.org/linux-mm/1556228754-12996-1-git-send-email-rppt@linux.ib=
m.com</a><br>
&gt; &gt;<br>
&gt; &gt; but, unfortunately, he won&#39;t be at LSF/MM.<br>
&gt; &gt;<br>
&gt; &gt; James<br>
&gt; &gt;<br>
&gt;<br>
&gt; Mike&#39;s proposal is quite different, and targeted at restricting RO=
P<br>
&gt; execution.<br>
&gt; The work proposed by Jonathan is aimed to transparently restrict<br>
&gt; speculative execution to provide generic mitigation against Spectre-V1=
<br>
&gt; gadgets (and similar) and potentially eliminate the current need for f=
or<br>
&gt; page table switches under most syscalls due to Meltdown.<br>
<br>
sounds very interesting.<br>
&quot;v1 gadgets&quot; would include unpriv bpf code too?<br></blockquote><=
div><br></div><div>Yes=C2=A0</div></div></div>

--00000000000021d0ec05876283c7--


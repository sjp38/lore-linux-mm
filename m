Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,HTML_MESSAGE,
	MAILING_LIST_MULTI,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9F58DC43219
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 22:26:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 92CCC206C0
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 22:26:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="dE1LsiCB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 92CCC206C0
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 757026B0005; Thu, 25 Apr 2019 18:26:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 705A86B0006; Thu, 25 Apr 2019 18:26:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5F3496B0007; Thu, 25 Apr 2019 18:26:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f200.google.com (mail-vk1-f200.google.com [209.85.221.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3A59A6B0005
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 18:26:29 -0400 (EDT)
Received: by mail-vk1-f200.google.com with SMTP id b10so622786vkf.3
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 15:26:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=0A8Ef9ZrnjmvBrdECZzU8uyrZVLgYAeK7aNL1c3AO4o=;
        b=bxjP/TRhZXKBkiJk1vhr7NMiGM4UcPHei5GwY88es0ZF0xmrBTtjq6/wolkp9CvHdX
         BffRffNaS4xFlhXkkpNaDdh/ZP2XpgtMETFFQcIfs14BVwzWgB6p5tooi+mQv0o3Fph1
         GVdzw70Ge+uxtj9USmbW7Ub9r9yTa6C0S2MRSfUc1+JwfwNu08MgYm/RS3nHZ1xsc0DS
         Ubr4mKe4nLKqkc3SdaQfN0TQcwlwZIpWeMgZoKs0yf5EXYFAI3T9beWrMsjrKgYpzyFL
         vPNa9EHoULueUwh9SXedHjC3Qt0bW5sybSoy0FduHoh9yj1naNB3uEyODVp1iLMqXCsY
         z+0Q==
X-Gm-Message-State: APjAAAVK17M9Lja9aL5esL7/jQJ3XilL6fJE0aZMzNFKM8gh4F/4Xjz3
	nZkyCJsC/dUqxwDlsORRAFUJa1b8mURNfHiT1inBE84TGbL4GFhNefD74OKkqQ1pWbWrsqcl5MK
	veBv7YH8oilS7Qg/d6GulB1YXjigeUlpnUBQEThpg4/f3e9tKA9TvZZTt9ey2UwPtPw==
X-Received: by 2002:a1f:f03:: with SMTP id 3mr7010731vkp.2.1556231188815;
        Thu, 25 Apr 2019 15:26:28 -0700 (PDT)
X-Received: by 2002:a1f:f03:: with SMTP id 3mr7010712vkp.2.1556231188035;
        Thu, 25 Apr 2019 15:26:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556231188; cv=none;
        d=google.com; s=arc-20160816;
        b=zuzMNyfcKB5YvTQwz1+70FjnJFADI4BzCgLDkmnW4vC9DBC7mdM5f7WmVTTAZuwIA+
         CxvtU/hysOy/kLKCW+43nzrCHT5ajTIzpeTY0dy/R94JC0HK4mAUFszX2VDy+5seI3sU
         kav2YPqLWTHE2cvY8j0TjzUfn5V2AL59hLQOt4V4jfYaX/70i1UTuUvmbhK+SNY/hae2
         OV7MuYFWfLsZWDHbpW2WaeOh99qnIbel/tUPwSN6E0lpXsXT4kYBl3OlILm69k3zO4le
         CdyMLrYuNd/L7M6qp7cMGwjUsi8Bhe4Pw94tUhlKpZF6A1tkMrnSx4xQph4dilNn1I1j
         YhEQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=0A8Ef9ZrnjmvBrdECZzU8uyrZVLgYAeK7aNL1c3AO4o=;
        b=whgvIooMcueD8+z2/LCC1GrkwYj/a7sjAOnpSaWvjJ0X3BWKHZfcIqwJ0YTLSb23GC
         mJ4QCn6dLNF1WTHLqXJCxxAvoHDoToxpNrm4WJ5Iagt0A7V+I6gVgXfb9aX/7qIUb/U3
         pu478RHAq7Ho7iK1DDJk9uQfUfwbtYkR2shmZAmM80cXYmt+Z3Y39LkEk1PSnlExrhkU
         BfO7HiA3mUFqPyKv9IWDe6GQALOsNPEZ+i0+QuoLDHJ3+Gn5iGCX0rJOsrZlNYoQhJEu
         jawljVZX+NzDMukLjm74M8F5OnbQjJjp1/6078Gz8LQ+DhqrX1pk4CI2cdg5yNPedMjV
         ogQw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=dE1LsiCB;
       spf=pass (google.com: domain of pjt@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pjt@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l19sor12638936vsp.15.2019.04.25.15.26.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 25 Apr 2019 15:26:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of pjt@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=dE1LsiCB;
       spf=pass (google.com: domain of pjt@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pjt@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=0A8Ef9ZrnjmvBrdECZzU8uyrZVLgYAeK7aNL1c3AO4o=;
        b=dE1LsiCB6LHEKmieYVfQqBNwcbb8Ew8gT4Ppw6sTnkVvd3ZH0TJeGtyzGnl+8R3GkE
         9syS7BmdOaY8ydlz7ZtLB2pH+3B2bXvWD2X9i42Z+a0i2OgrMXgfGD1jowwYa2FnRL8z
         DPX4IEKdAQpVDvx544cCqZ5aDFo7L/I+EcvYNX4HVZ6Qy/FyxK+0CfF//+Vtss85KTY2
         IWmFoVES1WKbNyf8tzA6q4XrAFy+JVQ+dgaplGjtYbGdEolcbC/+pN9fEYvaOeWvW94a
         VVsyGdBWTRnFlOlPSil+rvdzn5fi2yVFJmw+0+irjoDRhT6dWooysJxc01Gvk15G/NN/
         S4vw==
X-Google-Smtp-Source: APXvYqwstuca7t0wkUSumxZGseUpcgjJ8J8GpoXsW3grg0fY8rtKfHYJSsUQku5mI8qOaObyZtr8tOJSSebVEQTMgrg=
X-Received: by 2002:a67:b102:: with SMTP id w2mr4845695vsl.20.1556231187169;
 Thu, 25 Apr 2019 15:26:27 -0700 (PDT)
MIME-Version: 1.0
References: <20190207072421.GA9120@rapoport-lnx> <CA+VK+GOpjXQ2-CLZt6zrW6m-=WpWpvcrXGSJ-723tRDMeAeHmg@mail.gmail.com>
 <CAPM31RKpR0EZoeXZMXciTxvjBEeu3Jf3ks4Dn9gERxXghoB67w@mail.gmail.com>
 <CA+VK+GOOv4Vpfv+yMwHGwyf_a5tvcY9_0naGR=LgzxTFbDkBnQ@mail.gmail.com> <1556229406.24945.10.camel@HansenPartnership.com>
In-Reply-To: <1556229406.24945.10.camel@HansenPartnership.com>
From: Paul Turner <pjt@google.com>
Date: Thu, 25 Apr 2019 15:25:51 -0700
Message-ID: <CAPM31R+Wd=2ZMJmg3dZ37xnzHrsnMP6CYZrV+evqNY4Vb6Paqw@mail.gmail.com>
Subject: Re: [LSF/MM TOPIC] Address space isolation inside the kernel
To: James Bottomley <James.Bottomley@hansenpartnership.com>
Cc: Jonathan Adams <jwadams@google.com>, lsf-pc@lists.linux-foundation.org, 
	linux-mm@kvack.org, Mike Rapoport <rppt@linux.ibm.com>
Content-Type: multipart/alternative; boundary="0000000000001a19e50587624f55"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--0000000000001a19e50587624f55
Content-Type: text/plain; charset="UTF-8"

On Thu, Apr 25, 2019 at 2:56 PM James Bottomley <
James.Bottomley@hansenpartnership.com> wrote:

> On Thu, 2019-04-25 at 13:47 -0700, Jonathan Adams wrote:
> > It looks like the MM track isn't full, and I think this topic is an
> > important thing to discuss.
>
> Mike just posted the RFC patches for this using a ROP gadget preventor
> as a demo:
>
>
> https://lore.kernel.org/linux-mm/1556228754-12996-1-git-send-email-rppt@linux.ibm.com
>
> but, unfortunately, he won't be at LSF/MM.
>
> James
>

Mike's proposal is quite different, and targeted at restricting ROP
execution.
The work proposed by Jonathan is aimed to transparently restrict
speculative execution to provide generic mitigation against Spectre-V1
gadgets (and similar) and potentially eliminate the current need for for
page table switches under most syscalls due to Meltdown.

--0000000000001a19e50587624f55
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div dir=3D"ltr"><br></div><br><div class=3D"gmail_quote">=
<div dir=3D"ltr" class=3D"gmail_attr">On Thu, Apr 25, 2019 at 2:56 PM James=
 Bottomley &lt;<a href=3D"mailto:James.Bottomley@hansenpartnership.com" tar=
get=3D"_blank">James.Bottomley@hansenpartnership.com</a>&gt; wrote:<br></di=
v><blockquote class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;borde=
r-left:1px solid rgb(204,204,204);padding-left:1ex">On Thu, 2019-04-25 at 1=
3:47 -0700, Jonathan Adams wrote:<br>
&gt; It looks like the MM track isn&#39;t full, and I think this topic is a=
n<br>
&gt; important thing to discuss.<br>
<br>
Mike just posted the RFC patches for this using a ROP gadget preventor<br>
as a demo:<br>
<br>
<a href=3D"https://lore.kernel.org/linux-mm/1556228754-12996-1-git-send-ema=
il-rppt@linux.ibm.com" rel=3D"noreferrer" target=3D"_blank">https://lore.ke=
rnel.org/linux-mm/1556228754-12996-1-git-send-email-rppt@linux.ibm.com</a><=
br>
<br>
but, unfortunately, he won&#39;t be at LSF/MM.<br>
<br>
James<br></blockquote><div><br></div><div>Mike&#39;s proposal is quite diff=
erent, and targeted at restricting ROP execution.</div><div>The work propos=
ed by Jonathan is aimed to transparently restrict speculative execution to =
provide generic mitigation against Spectre-V1 gadgets (and similar) and pot=
entially eliminate the current need for for page table switches under most =
syscalls due to Meltdown.</div><div>=C2=A0</div></div></div>

--0000000000001a19e50587624f55--


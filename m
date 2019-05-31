Return-Path: <SRS0=007R=T7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C74BDC28CC0
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 02:24:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7C2BE25DDC
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 02:24:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="JXxqi0Aw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7C2BE25DDC
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1075B6B0278; Thu, 30 May 2019 22:24:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0B95A6B027E; Thu, 30 May 2019 22:24:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F10336B0280; Thu, 30 May 2019 22:24:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id B98AF6B0278
	for <linux-mm@kvack.org>; Thu, 30 May 2019 22:24:49 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id q25so6101024pfg.10
        for <linux-mm@kvack.org>; Thu, 30 May 2019 19:24:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:subject:to:references
         :in-reply-to:mime-version:user-agent:message-id
         :content-transfer-encoding;
        bh=IT7tL4ec+mYJULv7CprD8eq307BhvxplP1hxReJnmGY=;
        b=MKLGue1eU2gvPm4fPiWOAUh/t9lEstmOaAZViMGFOZnHKI6L9POfX9q/r8x1QZucGx
         8+EjOKOLWcFzMW8W4gKl49JGKGNv/5LuGKm90V8vvmd+76d+bdeyWBp8talE8YdwqLM0
         iOhNvf9WHzHioyToU8hyY85D8KayV/AmbczcFSGFIv1NTnBMaSo7eb7+nrzMX9nRN9pb
         GJnZ6MhnbT+kUqPrWKOfG624hG33Ax0Cy3NFGvP7VHyh1NLM6WajimpGXOSiXqRjsvKl
         uXR+B5KuWLYbZvsCYqSsm0zQMqwsq3ULlIGEBAVN0soGa6Qr+4FVjiq68prGSqqAQh63
         vdRw==
X-Gm-Message-State: APjAAAXCbTxihl6eX9zpNPedEyaINmaZJdZ2Jgs8QvGJ7/Tbod2qD/r+
	aNZUKH2bFPlUXfSFjjLBYm/Q/d+9ZFlJydV5vF9LeE5tfbZS2IMhyVNISasMhBhGF3YXSLFqM/W
	1wjplU1b6HPYZadnEyl7XJhlXrLFoRXdl+fcLd9fUQiGkZmxMUf8SMTMBgnnIcKP5qw==
X-Received: by 2002:a17:902:b682:: with SMTP id c2mr6731545pls.9.1559269489365;
        Thu, 30 May 2019 19:24:49 -0700 (PDT)
X-Received: by 2002:a17:902:b682:: with SMTP id c2mr6731495pls.9.1559269488394;
        Thu, 30 May 2019 19:24:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559269488; cv=none;
        d=google.com; s=arc-20160816;
        b=f2mEUxmiX5c92vTdrun6Rg27/E2IiofLd+wpg/7IOOZb4hCuaxXHPdOOUe5GmCeGW3
         vZZZrToYbwlOGtHwf5MD7IvNE7xxjzWcWDJbc7zH5jP4Gylf8HFP21bMHyfjBMj4lj8k
         Tg9pCwhlA1AsIHHsqJIajlvSqnly8ovOgjHJ/43H1+q2U2PLfBuJhk7xDtJqYrtNV3sb
         3Mlo4Y1DpFkUHhpJ1QphZSniXmtSKTxzRUaSt8r1sMsh19MTmiafwR18rjr6Y4tkKC1C
         Jxg4bBSbE9lx4ZgItfSg8sc/JhLr5CoNOZKQ7GcpHqJHMzMTh0vwbc0/zaytgZxAODpA
         AU5A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:message-id:user-agent:mime-version
         :in-reply-to:references:to:subject:from:date:dkim-signature;
        bh=IT7tL4ec+mYJULv7CprD8eq307BhvxplP1hxReJnmGY=;
        b=0fjGFak3jJaHCHci4iL5WA5fHKEa7nGtFoxdqZCVQRbE73PIQfBFWrMO4+pWwesJgv
         LYn9dGyV+q/f1W2mag4CfV6OAzjdU2563qewb29tIbAcr0PS3d/RwBoeRcgm2JQEQ/E3
         SutaHnj+pcSS9q1t/V4UjPb5Zzz9S0LWKroET4eAyuAql+huxihM37lzeShD2IrUZnbi
         YMW6IzG1nwuFA6R8UGU80mFnK27H5RKwHzNK2bwlOHNs+4sLGcxrB6LaoLcDhbdL760n
         wwV0tL8kwKWDAjhlnU67n/Ye1VIEubasKFGtP3+jq4Y7R9lLk+NQhiWHNWITSFl9GEbf
         AOWw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=JXxqi0Aw;
       spf=pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=npiggin@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m184sor4861135pgm.36.2019.05.30.19.24.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 30 May 2019 19:24:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=JXxqi0Aw;
       spf=pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=npiggin@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:subject:to:references:in-reply-to:mime-version:user-agent
         :message-id:content-transfer-encoding;
        bh=IT7tL4ec+mYJULv7CprD8eq307BhvxplP1hxReJnmGY=;
        b=JXxqi0AwqnyanwvX2sm45PLy+OW7/6yCN9kfD6O/qyWOHVeSGoIKgnnRgjTApwQ78+
         K6tw4gsGLKKKSCypzthPDlb9EtnFIGoGG35lMfef+u+kVV/qc0aVieqT6MBOJT7ghvir
         Xyxmvmelc5hmV7p1+WCp4Ioln7MpeLiqber3GyIarsifm4RJ9e0S5TAtopaiIPNWn5zG
         z1dbP2lQWii6QGP5b3nSkT/KyO0PiBACANBZkrBuRllSMAutzG+JdlYE8dbCCDNIUR9R
         7NGRlkgl7y64bb3kKKGH0Jd1yIILdvJsN2U4Ul/D9ywtf3BH7YulxXPMaMs/5yfk5uO9
         +q0w==
X-Google-Smtp-Source: APXvYqylwF2vBW4G23aaB7l8Kfyn367nP02thZAoCMuzMFg+RuqO583xQ2eA6Z9hVgwEqmWGvf5aLw==
X-Received: by 2002:a63:480f:: with SMTP id v15mr6452422pga.373.1559269488063;
        Thu, 30 May 2019 19:24:48 -0700 (PDT)
Received: from localhost (193-116-81-133.tpgi.com.au. [193.116.81.133])
        by smtp.gmail.com with ESMTPSA id b35sm3723852pjc.15.2019.05.30.19.24.44
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 30 May 2019 19:24:45 -0700 (PDT)
Date: Fri, 31 May 2019 12:24:27 +1000
From: Nicholas Piggin <npiggin@gmail.com>
Subject: Re: [mmotm:master 124/234] mm/vmalloc.c:520:6: error: implicit
 declaration of function 'p4d_large'; did you mean 'p4d_page'?
To: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner
	<hannes@cmpxchg.org>, kbuild-all@01.org, Linux Memory Management List
	<linux-mm@kvack.org>, linux-arch@vger.kernel.org
References: <201905310708.EAdSCJKR%lkp@intel.com>
In-Reply-To: <201905310708.EAdSCJKR%lkp@intel.com>
MIME-Version: 1.0
User-Agent: astroid/0.14.0 (https://github.com/astroidmail/astroid)
Message-Id: <1559269231.3e5ttes2dd.astroid@bobo.none>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

kbuild test robot's on May 31, 2019 9:42 am:
> tree:   git://git.cmpxchg.org/linux-mmotm.git master
> head:   6f11685c34f638e200dd9e821491584ef5717d57
> commit: 91c106f5d623b94305af3fd91113de1cba768d73 [124/234] mm/vmalloc: hu=
gepage vmalloc mappings
> config: arm64-allyesconfig (attached as .config)
> compiler: aarch64-linux-gcc (GCC) 7.4.0
> reproduce:
>         wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbi=
n/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         git checkout 91c106f5d623b94305af3fd91113de1cba768d73
>         # save the attached .config to linux build tree
>         GCC_VERSION=3D7.4.0 make.cross ARCH=3Darm64=20
>=20
> If you fix the issue, kindly add following tag
> Reported-by: kbuild test robot <lkp@intel.com>
>=20
> All errors (new ones prefixed by >>):
>=20
>    mm/vmalloc.c: In function 'vmap_range':
>    mm/vmalloc.c:325:19: error: 'start' undeclared (first use in this func=
tion); did you mean 'stat'?
>      flush_cache_vmap(start, end);
>                       ^~~~~
>                       stat
>    mm/vmalloc.c:325:19: note: each undeclared identifier is reported only=
 once for each function it appears in
>    mm/vmalloc.c: In function 'vmalloc_to_page':
>>> mm/vmalloc.c:520:6: error: implicit declaration of function 'p4d_large'=
; did you mean 'p4d_page'? [-Werror=3Dimplicit-function-declaration]
>      if (p4d_large(*p4d))
>          ^~~~~~~~~
>          p4d_page

Hmm, okay p?d_large I guess is not quite the right thing to use here. It
almost is, but it's tied to userspace/thp options.

What would people prefer to do here? We could have architectures that
define HAVE_ARCH_HUGE_VMAP to also provide p?d_huge_kernel() tests for
their kernel page tables?

Thanks,
Nick

=


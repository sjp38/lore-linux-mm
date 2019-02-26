Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3A043C43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 00:07:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E16C4217F4
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 00:07:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b="bNZr7nXI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E16C4217F4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6A3638E000B; Mon, 25 Feb 2019 19:07:33 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 678308E000A; Mon, 25 Feb 2019 19:07:33 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 51B078E000B; Mon, 25 Feb 2019 19:07:33 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id D4D648E000A
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 19:07:32 -0500 (EST)
Received: by mail-lj1-f199.google.com with SMTP id 202so1779843ljj.10
        for <linux-mm@kvack.org>; Mon, 25 Feb 2019 16:07:32 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=0/RCL+H9yC/RWFMtaWm284KCaP64OOSmBn5G9YZ2KtA=;
        b=LUA7dwffG/4dFa025HLkE0eCdKz42kkbbjj+LBZdL970+pd7BcUhi69XXG4I8Tigd/
         Yb1S/bIEFzi405Y6ZVeOIa8EpxfXl/mQubkpaIt6tNml8/Y5Km2B2hW+qn+Lam5xyj6d
         y3DjZNOjFuLan6Vq/mEi9765P7J56KW4Hc8PJH3LZBJQHmWXO+r29eI7IuwPxy4nvnyG
         m0OvQ7Zqt18hVPXHf9FIJYL+n5hGDq74ygr3lWOsItqGVtPj8872KTCSA7s4qOILlx9F
         CIUZPeg3cwxeIZIVZHAqnUURnVbEBPk6sm/BpAhRaxTcsqeK1EOYyripnuH1mC0ip1UY
         RIwg==
X-Gm-Message-State: AHQUAubkf5dPin2r6Pjdu6HR3nTxy2gzzERgt6nCoUVF1Mi5FyPSgAgA
	O+xb/dsDQJfq/YMpnCq4j7JjZP+OlksbMRhWg0KN5DR8NcBqwLRQ0409U6rAKQfBrEvaDUSRQCP
	Uv7m2bKrL0oaziQXe3GUybdhDigMPg03ea4FTDQ8yTMKI+5GMmy3cH5D37CfJWz9ZRqs/eXi/zO
	m6cXIuIxzx4mpogow+1mm2o3oGdcldTd/GgdqKNsIEKncZxDC6dUNiQd+hu+sut4PJfK1Kar5fA
	xPU26GMaRnxpeJYYwZtHCZfCCb6l+FMinIXAhp5PUm6zKf/OR5T3nA3Gjsr1A3tPvK65HyBDvMG
	u8AAMI79RmeCQOnArh75PP43JFiwKT7gseV7r2xxa0sDHZ9naby+fPWSzppVzL+wBqBfoxrpUJ7
	n
X-Received: by 2002:a19:c301:: with SMTP id t1mr4368964lff.95.1551139652215;
        Mon, 25 Feb 2019 16:07:32 -0800 (PST)
X-Received: by 2002:a19:c301:: with SMTP id t1mr4368938lff.95.1551139651316;
        Mon, 25 Feb 2019 16:07:31 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551139651; cv=none;
        d=google.com; s=arc-20160816;
        b=0B7zADe1I2XGsC9EPQqI+cX6efud28oqeaby5UNcd19fGAWsSOL31WEfIwXqj6BiWT
         ZpVqeJ7KxMYAyZ1oz0vfKDIVJ/djsvfOOZDlsfPK3hD20OOz33B4K9244KLzqdcM5sbK
         zNICB/+dwisqdtGchNRrDeBNWpQnPsY7a7TE8Z2uZLUA5YajSmEVWepE4oOx6pXiz3WD
         /0aIsKlmIDYeauZoJMs2jncFQCR93zWz7XsVJWlJrcOAiNoBFYC63KBsxdAN2gSsmo68
         Uy+0kVtDEMu7KKREhqw9hOPBwSrz8mRECOab0wZyztS30dSgGL2An7X3eK66DulDpdCZ
         leDA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=0/RCL+H9yC/RWFMtaWm284KCaP64OOSmBn5G9YZ2KtA=;
        b=jI4ZgQRgkUaXCbjvC1fL4bzOG4VxN0IqxJXaaEbVkTyh5N/r0CoiaJzaClXKplMpyZ
         mqo4x+pihXoA65yI/2wvqJyoGxCGaxCI+fcNhGd/J+Zfwe2qUlkTjfAktxnKgfuARbZV
         cMuEJg9D0qB9bBeW7PVoYnhMXMsA2acmHDZO2gjyPMppXxvs1TJvt0sCa/EDFIF5HnhI
         XAd4qEBTm108B+3Qzxi2IItPMhFOEhx4nEgkbUovyb081QwOWcQEsltPIMhD8MPQsNkw
         XJV5w9AJK1UsH913eL2S46as0jkcWUyqLw2z2LiCDmZjIP7GENrJvhE/EamcDmQbogoR
         Jzhw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=bNZr7nXI;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i26sor5747621ljj.17.2019.02.25.16.07.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 25 Feb 2019 16:07:31 -0800 (PST)
Received-SPF: pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=bNZr7nXI;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=0/RCL+H9yC/RWFMtaWm284KCaP64OOSmBn5G9YZ2KtA=;
        b=bNZr7nXI+nIktrAxf5ZjL1b7XP4SSnerSSU1J8dZOjk6LLGkSlefNh6KNOMaAxUP9u
         m2XpNxKf3eJLN3njAYmwKY0KuQSXY+s+ijf1ib1CUS3T6gjAfGM6JVVd9dZ6/Le/ISG6
         qF+2IPWv+qy16dnaD1+WDd7yY2DMNYpVUumbU=
X-Google-Smtp-Source: AHgI3IYLARextt+Ksu0KPedDMKMM2utxPP9mfiJbNThcrLU9Wrk7NQUnSf8DrKKdK0l4zO31lyTUBw==
X-Received: by 2002:a2e:12da:: with SMTP id 87mr11539228ljs.181.1551139650117;
        Mon, 25 Feb 2019 16:07:30 -0800 (PST)
Received: from mail-lj1-f181.google.com (mail-lj1-f181.google.com. [209.85.208.181])
        by smtp.gmail.com with ESMTPSA id i21sm2811481lfj.60.2019.02.25.16.07.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Feb 2019 16:07:29 -0800 (PST)
Received: by mail-lj1-f181.google.com with SMTP id v10so9133576lji.3
        for <linux-mm@kvack.org>; Mon, 25 Feb 2019 16:07:28 -0800 (PST)
X-Received: by 2002:a2e:9786:: with SMTP id y6mr10251793lji.79.1551139648545;
 Mon, 25 Feb 2019 16:07:28 -0800 (PST)
MIME-Version: 1.0
References: <20190221222123.GC6474@magnolia> <alpine.LSU.2.11.1902222222570.1594@eggly.anvils>
 <CAHk-=wgO3MPjPpf_ARyW6zpwwPZtxXYQgMLbmj2bnbOLnR+6Cg@mail.gmail.com>
 <alpine.LSU.2.11.1902251214220.8973@eggly.anvils> <CAHk-=whP-9yPAWuJDwA6+rQ-9owuYZgmrMA9AqO3EGJVefe8vg@mail.gmail.com>
 <CAHk-=wiwAXaRXjHxasNMy5DHEMiui5XBTL3aO1i6Ja04qhY4gA@mail.gmail.com> <86649ee4-9794-77a3-502c-f4cd10019c36@lca.pw>
In-Reply-To: <86649ee4-9794-77a3-502c-f4cd10019c36@lca.pw>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 25 Feb 2019 16:07:12 -0800
X-Gmail-Original-Message-ID: <CAHk-=wggjLsi-1BmDHqWAJPzBvTD_-MQNo5qQ9WCuncnyWPROg@mail.gmail.com>
Message-ID: <CAHk-=wggjLsi-1BmDHqWAJPzBvTD_-MQNo5qQ9WCuncnyWPROg@mail.gmail.com>
Subject: Re: [PATCH] tmpfs: fix uninitialized return value in shmem_link
To: Qian Cai <cai@lca.pw>
Cc: Hugh Dickins <hughd@google.com>, "Darrick J. Wong" <darrick.wong@oracle.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Matej Kupljen <matej.kupljen@gmail.com>, 
	Al Viro <viro@zeniv.linux.org.uk>, Dan Carpenter <dan.carpenter@oracle.com>, 
	Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, 
	linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 25, 2019 at 4:03 PM Qian Cai <cai@lca.pw> wrote:
> >
> > Of course, that's just gcc. I have no idea what llvm ends up doing.
>
> Clang 7.0:
>
> # clang  -O2 -S -Wall /tmp/test.c
> /tmp/test.c:46:6: warning: variable 'ret' is used uninitialized whenever 'if'
> condition is false [-Wsometimes-uninitialized]

Ok, good.

Do we have any clang builds in any of the zero-day robot
infrastructure or something? Should we?

And maybe this was how Dan noticed the problem in the first place? Or
is it just because of his eagle-eyes?

                  Linus


Return-Path: <SRS0=4gxf=RO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 44C83C43381
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 14:01:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0C56A20657
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 14:01:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0C56A20657
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arndb.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AD6888E0005; Mon, 11 Mar 2019 10:01:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A849D8E0002; Mon, 11 Mar 2019 10:01:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9758B8E0005; Mon, 11 Mar 2019 10:01:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7101F8E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 10:01:10 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id e31so5253213qtb.22
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 07:01:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :references:in-reply-to:from:date:message-id:subject:to:cc;
        bh=NAVSCLI4bpYkN0vehk8e+9hfFe+zl25LDlWzCtnVJs4=;
        b=aMoU96a39Nlsk6uPkZiC/zkwZksy/lSlGJ2Nft5KhVbjenaPuQ/RtM8+of1aTgwYhi
         DH3Rx4kILhvK2LOSit53STJqnmNyrIlt0y2fQtku38MWfKgqAPc7Vlff1su0Kcp2Pfn0
         meZVH/l6+40nZrTCOVJw8c3D4eeUhrCn3ruh/5Cu7vYs2oiK9JA3vnMAR7Rrb9JYnqz2
         CcAbgkOO2Hgxuxy4RiqL2xR09Jk7I6Obg8G4QVMxm8HuR62VvbnlS+21ehOR+V4Ifmnf
         2Bfn/bZaOim/LUWW/vhbuD5hYEiTgqAD8444bsMD3VfdpVKEUM1SNvzcCkuWG0hJxqnj
         REWQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of arndbergmann@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=arndbergmann@gmail.com
X-Gm-Message-State: APjAAAXxF7UUbZYxOAUq6o8HBsTTjhcSn0a7/3QjS9ZJ0aM8QuvWqmOx
	pNP3dkRrxrdQlknwiff+0ckpeZLAtJ9W/YvlywESJvYiTJjUgUw8N2sMG0JrHQ3ILTJBMBnZpB/
	esBU+BIjUlDMo1i/GwrDvNdO2pjVfiAo7DQyCvMTVhZVDX9rc7IulrMB4hXCUKKCALccY6Cfh5y
	6DSsfpf42nTZFpYOPpiI+iMfdSdgdcOwtWbh5Rn/nBw0Pp90ywT/6v9CQMje/80aseFpE65xY3m
	0S1ooX/zgv2WyETxe/UYv0ko0h/lrTgFDtp5UliMX4wh7wL3MLdPHK9mzx1f7j2+aKPlZJF9Ea5
	yAG5br4iXn4zCSGx3O1vNg/r0LtxbbeOrkognk0CWjJwWhWaKBBE6QlEG4k+HIAxQBpCFo2cFw=
	=
X-Received: by 2002:ae9:c30f:: with SMTP id n15mr1875011qkg.227.1552312870262;
        Mon, 11 Mar 2019 07:01:10 -0700 (PDT)
X-Received: by 2002:ae9:c30f:: with SMTP id n15mr1874942qkg.227.1552312869494;
        Mon, 11 Mar 2019 07:01:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552312869; cv=none;
        d=google.com; s=arc-20160816;
        b=u+2pXRYSECzaFDsghyLsgubZdgugXu93I0ELwaZZQulKqP2HB/kWVQX/7EFRDcug+l
         NqNIs3rtQya3xQIRVnsfQKahOeFbVRPHNoVjCUdrPn9iFMFLajfHeAsAswV9pbUatKIR
         RLw+VSBLPkB57m7ZR1GPTtOYgOg834woEbzfX6iUEJjdFmUG+OcZl/IetStHZuB9j+8U
         wrHKjW4cVhWBH4Ph7tXhZ6oxoBnErY8088CizIIHY4/k9VEnAORTDmEbsKxsODgPtE3S
         Hk934Mv7YyFB3o1ghupRC7yYiEAsw8oMCrBgpeWnfey2zK1KJL03D5QBzrnTWUq9nbix
         s4FA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version;
        bh=NAVSCLI4bpYkN0vehk8e+9hfFe+zl25LDlWzCtnVJs4=;
        b=nSlM58ix0Ak9tKSEIaebXGrSPyg0e6tvF3tRF7krdTZNWr0kXBNsw6oGDkHgyvBH57
         RYvuS9fQV+Z6syiUU0prqVxFQUHtxfq/MrlM+225iN8UhhSyEkohB7kmini6bReK3gf/
         fJ1g4mvqP0TlZ415loA/3wooOz8fmLOGJt11ENMsS7cl3l1uGIwdbINdmUJCgFfDsZLm
         /jY9br14ZBZVUiLMDMI525cIzT3+5y+S6Ne34MnD+c9ASoGBY3DkvhhvHddAfdFtj2mj
         kpuLm5SIooXTkc96BfuyLqtCX5lRH13Zf3LrqnC6Z95WBlvssc9DVjt44YS3euk3EGSU
         0wrQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of arndbergmann@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=arndbergmann@gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z43sor6184828qve.15.2019.03.11.07.01.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Mar 2019 07:01:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of arndbergmann@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of arndbergmann@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=arndbergmann@gmail.com
X-Google-Smtp-Source: APXvYqxsIdm3BSNVGFp9FsU9rosmUSaPmP2VP43e8DD+SIqNd/ILmWEbKSwxunuPwJTx91N1nbWiyX+pBuqhbxBTK2A=
X-Received: by 2002:a0c:b501:: with SMTP id d1mr26308451qve.115.1552312869102;
 Mon, 11 Mar 2019 07:01:09 -0700 (PDT)
MIME-Version: 1.0
References: <20190310183051.87303-1-cai@lca.pw> <20190311035815.kq7ftc6vphy6vwen@linux-r8p5>
 <20190311122100.GF22862@mellanox.com>
In-Reply-To: <20190311122100.GF22862@mellanox.com>
From: Arnd Bergmann <arnd@arndb.de>
Date: Mon, 11 Mar 2019 15:00:50 +0100
Message-ID: <CAK8P3a1PpgjRKFemEi7mLuECh1srs8bbzoc07RSrFsx+febjaQ@mail.gmail.com>
Subject: Re: [PATCH] mm/debug: add a cast to u64 for atomic64_read()
To: Jason Gunthorpe <jgg@mellanox.com>
Cc: Qian Cai <cai@lca.pw>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, 
	"linux-mm@kvack.org" <linux-mm@kvack.org>, 
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 11, 2019 at 1:21 PM Jason Gunthorpe <jgg@mellanox.com> wrote:
> On Sun, Mar 10, 2019 at 08:58:15PM -0700, Davidlohr Bueso wrote:
> > On Sun, 10 Mar 2019, Qian Cai wrote:

> >
> > Acked-by: Davidlohr Bueso <dbueso@suse.de>
>
> Not saying this patch shouldn't go ahead..
>
> But is there a special reason the atomic64*'s on ppc don't use the u64
> type like other archs? Seems like a better thing to fix than adding
> casts all over the place.

Agreed in principle, but I'd note that it's not just ppc64, but almost all
64-bit architectures. x86-64 and arm64 changed over last year
from returning 'long' to 'long long', apparently as an unintended
side effect of commits 8bf705d13039 ("locking/atomic/x86: Switch
atomic.h to use atomic-instrumented.h") and c0df10812835 ("arm64,
locking/atomics: Use instrumented atomics").

It would be nice to just do the instrumented atomics on all 64-bit
architectures for consistency, but that would be a lot of work, and
would not actually give us additional instrumentation on most of them,
since they don't support KASAN (except s390).

       Arnd


Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,FROM_EXCESS_BASE64,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EFF80C169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 16:22:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A40B2218F0
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 16:22:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="jkXD9mqf"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A40B2218F0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 40CCF8E00F9; Mon, 11 Feb 2019 11:22:03 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3BC648E00F6; Mon, 11 Feb 2019 11:22:03 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2AA638E00F9; Mon, 11 Feb 2019 11:22:03 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 02C108E00F6
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 11:22:03 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id h6so12481852qke.18
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 08:22:02 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to
         :content-transfer-encoding;
        bh=cW7tWR8jGU6zZ9qwHpZvVc4mElp1JZn1A2mPsX4Px5E=;
        b=qNmKjYhck3OO9JEdxQxxU5uLquZY5Dc+MXtwOGi83cKY9TOW4DYQ91kLxgnwjoAOja
         xP53C2ZiNwpkeuft+E8EC2p9xKrNimhGRjGtwjs1tko7rmxBI6tD0wqqv40eHghTgqdY
         swxlbCtOl8mlYcUSJacoTLWz2+9ctHpvHRsYpS5HuUX0eO1qbJK0IRc5Lw10oZO/DWcQ
         uzAu2W2SGjQ3SyYYoRUTjoYDEyDLsqlPNjL1HBKjZ6HN7ASUB2CpTiqHCwRUIlAEGI66
         LOQGH4MPJrWLJyrXSPmWexLJkkoHXUpL6JNf9qsuSmRX5OGj526qnnxCK8l4he9EW+y0
         MbEA==
X-Gm-Message-State: AHQUAuZyQudSxq9Bj5E9zZm1PSZZzq5J0HB3zv3bB7VwU7hj91eT/Adg
	l+ypHZIUuz1G635OnWBjwKllVCSFdjvFzh3Ma4SScVhRqaBv08nVxuY219JlYnvyNMRqVVKOH+m
	pIJe5b383H/0ugEn3YIqV93s904prq47a4F5ISlHEiHgq+yQKpHpg4mwKKFyx34dSDtA+57eFxd
	TnZVz6256QLfbSJb73jcPjD24xJfYKwj1NrvlUBtOQr41RU1QATsLyuSXvLd5TycMGHDW+sy/Oj
	6kMwbaO556cjcTuhBD0k5Y3+77Z22QPZBT2slsaXRHr0H6tMUrwsFMgpWBeBwtIizXtHOZ4j+oV
	4vBc+kJSXFKLd4bKKdnk2TjzLSxi+95sLf11Wc5MLHtGwXOqaMTvHA/cSpXcOvsRASfb2+35vK6
	7
X-Received: by 2002:ac8:2782:: with SMTP id w2mr5488103qtw.8.1549902122622;
        Mon, 11 Feb 2019 08:22:02 -0800 (PST)
X-Received: by 2002:ac8:2782:: with SMTP id w2mr5488053qtw.8.1549902121839;
        Mon, 11 Feb 2019 08:22:01 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549902121; cv=none;
        d=google.com; s=arc-20160816;
        b=gYFWWu/Ev1vpTbuAApTKttEpybqp+MgSAwuqKrC8BTqO/mZf3IBmP/aNEswZYJttWV
         jG+pba3ZzmF2PBe2azFpVSc6g7sJjD7UL+VEbdBx8TOa6FgTWekQCv3iiZHjqpxgUGEx
         DSG2PqcEAc5WY5APO+UI44w41ef+PHApA712oD8tlH/kI2idyjvdYRxNHwAn7X38xg+F
         2lU6SJhX1Kxw/0ipOWGPP2N3S2McWoklMg3dHPHFXiF9my53UFa3HaIrPinC4Hix9spW
         PW+qTzweygnD3A8uFxm63i3jN++8oqA1ymjT9jWJAX+X/g7BL0z6qsGWZoL8Q8r2gKN8
         brYA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=cW7tWR8jGU6zZ9qwHpZvVc4mElp1JZn1A2mPsX4Px5E=;
        b=uahYG7I6ey/crheY2odztRRd2ARYEyz+9zOa04Zy2lTys7pPOrCEKJSvk+6r6qoBo5
         vxPhjZj3ezQhTkVudGUJGGUqk7nhNMqMkdmUlkS/PpNqFSjhhM5cE0nfK3r3N81x1wYx
         0QApb1XlY47mbu6/AdYFggeIveOFONalQyMvqdfX21Ull/QptGu4IeClnMvHQH7sxsyv
         Otoke49HQAmHzJdz1xg8XtPPQh8aXbUIBMnDscPI08KagowZNqFHFQGej11FM+oLqBST
         um7rTZ46/scDJylLLC8Iz+H6Birnh8wjP0Gw5X2sNQHRRjemtGIdSuNsIf9foo2yBP7V
         w6pQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=jkXD9mqf;
       spf=pass (google.com: domain of bjorn.topel@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=bjorn.topel@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w191sor5285071qka.50.2019.02.11.08.22.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Feb 2019 08:22:01 -0800 (PST)
Received-SPF: pass (google.com: domain of bjorn.topel@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=jkXD9mqf;
       spf=pass (google.com: domain of bjorn.topel@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=bjorn.topel@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :content-transfer-encoding;
        bh=cW7tWR8jGU6zZ9qwHpZvVc4mElp1JZn1A2mPsX4Px5E=;
        b=jkXD9mqfWW3yXbG8w0LZFxPfA2yQmsA507fb3oPSKudLwSr06rY7lKpkWsvp8gyDJn
         mje9T/31t+keyaV3PDToa5jAAqyUX0WsaHAXW8uu5aNkYlsraE48lbYzzv6U9yDLV4DE
         D1bba6Y9KgNsImsmZRm+vMjRY41YyAa9YO9js9RqBukfHHYtFTWkW98IqIoxCMaMN/Jy
         vVWRtyqmN6jy+0UPJTNdAW1oupFbp1TsG5ZjpU0A2TY+Fxr9Qs3klWX3R0VgbUdMWgAz
         CME4zS9naGnbE6twvA7xihqe1qIy1F+npUtRSk0Xs6lBYc9TlTuXH6bKsmQ7IHT+f8z0
         ppVA==
X-Google-Smtp-Source: AHgI3IbCQXC33QsGEJonTzW4/yy3yyPzPYZR6ATkgkmltAkIDqUglEFH2FjqqLfUZUyNdEMGxCHBmpiXk0ANAVD3Izs=
X-Received: by 2002:a37:5807:: with SMTP id m7mr26465615qkb.141.1549902121590;
 Mon, 11 Feb 2019 08:22:01 -0800 (PST)
MIME-Version: 1.0
References: <20190207053740.26915-1-dave@stgolabs.net> <20190207053740.26915-2-dave@stgolabs.net>
 <20190211161529.uskq5ca7y3j5522i@linux-r8p5>
In-Reply-To: <20190211161529.uskq5ca7y3j5522i@linux-r8p5>
From: =?UTF-8?B?QmrDtnJuIFTDtnBlbA==?= <bjorn.topel@gmail.com>
Date: Mon, 11 Feb 2019 17:21:49 +0100
Message-ID: <CAJ+HfNj3jwqT7980grynDp7sPj6XL8_JFgs5AK6Zhhj7spRpTg@mail.gmail.com>
Subject: Re: [PATCH v2] xsk: share the mmap_sem for page pinning
To: akpm@linux-foundation.org, linux-mm@kvack.org, 
	LKML <linux-kernel@vger.kernel.org>, "David S . Miller" <davem@davemloft.net>, 
	Bjorn Topel <bjorn.topel@intel.com>, Magnus Karlsson <magnus.karlsson@intel.com>, 
	Netdev <netdev@vger.kernel.org>, Davidlohr Bueso <dbueso@suse.de>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Den m=C3=A5n 11 feb. 2019 kl 17:15 skrev Davidlohr Bueso <dave@stgolabs.net=
>:
>
> Holding mmap_sem exclusively for a gup() is an overkill.
> Lets share the lock and replace the gup call for gup_longterm(),
> as it is better suited for the lifetime of the pinning.
>

Thanks for the cleanup!

Acked-by: Bj=C3=B6rn T=C3=B6pel <bjorn.topel@intel.com>

> Cc: David S. Miller <davem@davemloft.net>
> Cc: Bjorn Topel <bjorn.topel@intel.com>
> Cc: Magnus Karlsson <magnus.karlsson@intel.com>
> CC: netdev@vger.kernel.org
> Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
> ---
>  net/xdp/xdp_umem.c | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
>
> diff --git a/net/xdp/xdp_umem.c b/net/xdp/xdp_umem.c
> index 5ab236c5c9a5..e7fa8d0d7090 100644
> --- a/net/xdp/xdp_umem.c
> +++ b/net/xdp/xdp_umem.c
> @@ -265,10 +265,10 @@ static int xdp_umem_pin_pages(struct xdp_umem *umem=
)
>         if (!umem->pgs)
>                 return -ENOMEM;
>
> -       down_write(&current->mm->mmap_sem);
> -       npgs =3D get_user_pages(umem->address, umem->npgs,
> +       down_read(&current->mm->mmap_sem);
> +       npgs =3D get_user_pages_longterm(umem->address, umem->npgs,
>                               gup_flags, &umem->pgs[0], NULL);
> -       up_write(&current->mm->mmap_sem);
> +       up_read(&current->mm->mmap_sem);
>
>         if (npgs !=3D umem->npgs) {
>                 if (npgs >=3D 0) {
> --
> 2.16.4
>


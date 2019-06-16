Return-Path: <SRS0=z6ed=UP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 258B4C31E54
	for <linux-mm@archiver.kernel.org>; Sun, 16 Jun 2019 10:12:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AD9E8216FD
	for <linux-mm@archiver.kernel.org>; Sun, 16 Jun 2019 10:12:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Sp0zNssZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AD9E8216FD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 05C1C6B0005; Sun, 16 Jun 2019 06:12:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 00D908E0002; Sun, 16 Jun 2019 06:12:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E64FC8E0001; Sun, 16 Jun 2019 06:12:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id C79806B0005
	for <linux-mm@kvack.org>; Sun, 16 Jun 2019 06:12:49 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id m1so8658303iop.1
        for <linux-mm@kvack.org>; Sun, 16 Jun 2019 03:12:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=dXi83X39sc+SHqsRQb9qWakQ658qfuo/1ekg8hliBD0=;
        b=poVPjHpVyOcgyH085DqBQ7Wic/dgmEO/PC65gVLrEVDgbO/vRpUtKyFqqQvuokWYpF
         2mEj1NopRc/vrHyLdyRCP7Lek2mKKIVNTGSrOEORijWrLR6M2xvyFFshBfok4w0Y7bBL
         qfsC2l3Rr/QeMmORr5MDUeYSMJd4spAnF2mVljdLIJgImEI9VmYiU1JGu7Glisvs5NYT
         VCn7bu67ILli4wOELM8+6qkMbHTCPYpJQnpkxyJAzFb5lsWEzdCIAQ20QxKMeIU00Irz
         h4qpv8asSh9XoqH5qqdRwPnnkjh7ier8eO1soLEhEMsUMaA1J2mOkaqKQ7lm40DcyjHZ
         GujQ==
X-Gm-Message-State: APjAAAXzQMgZT7FFcx3FsI0zWYvO2K4uPuvvg0qsGD4bfq0rhfpp1nmh
	sinDcilLI5fdFiYUtcaOkzMCmTbadlYXxMuFwjCQA0+eSP0vJdQ0nmwP7Xy8Pd7fBixnvz/obCl
	Rqjwv2WoI3LuXRy9KYfpSVFYn8BNmyCAo3C3221hr855ZKlM9KcooWMaqAQp2TFSUOA==
X-Received: by 2002:a02:234b:: with SMTP id u72mr78123376jau.4.1560679969433;
        Sun, 16 Jun 2019 03:12:49 -0700 (PDT)
X-Received: by 2002:a02:234b:: with SMTP id u72mr78123316jau.4.1560679968552;
        Sun, 16 Jun 2019 03:12:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560679968; cv=none;
        d=google.com; s=arc-20160816;
        b=P98dSba4VN1abgBHsIbuhS3+AnyTmT/dr7uoMgkjXbTbfRPD7XUbZLf2vPmw83bCTP
         wBjI+g7jfAdY/sv16ks0tWRf7VF9/Vn+AP96rep06mn6VEqwTzX48yd6XBwThd+niIoM
         Pt4UZOPigh7LDtQkjgtg7/FCXXx35ofhY9V2W+ZtBepo6MfrwmLBEXyHQP9O+tFx21/Y
         iG2bU0NIfLXeyyuzthTG6KhkEd+gzwZL6vJWRpwl+1ywWxP3zZgbM/q1nc7Toj3QzQVZ
         3jMl52+GQV6nnIdXhqvYr1WJ/HVQojwiZi4dgwS3G0Di/SUxwc17HnTF+vV9s8ZYv7QT
         v5Tw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=dXi83X39sc+SHqsRQb9qWakQ658qfuo/1ekg8hliBD0=;
        b=t1Pe2oBVT/1A8SqNOOwcRgxDgdXNXszmjBSMFarwBfWEuQrAYzxHVVxuAzBdlT0X8k
         ZcCxFr5bJTSLAFa623nfK1NCPAmM0Y5dcuFeQJlVCtUFielnQPb7cu8eXd9X6aEu5ZwJ
         yhmn1cL+y2ozmP+IuZwKhYMU3huxCyL8Pya/H4EKBLoFgeNDXZhLTs+0byPfTop5syTS
         48LlRcIL+cvGnIRWB4sTCY95y6we+5MuNeztSZYSH+8APZ7PPsvarTFpYmKv+WmeQUJ2
         fbqzuxW80UO96Jg8xKFuJjR1KITL17jjwhio88aTs558wIEN58tJtAfrtEGX9WHVZmvK
         O/Kw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Sp0zNssZ;
       spf=pass (google.com: domain of mikhail.v.gavrilov@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mikhail.v.gavrilov@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i26sor20766384jaf.1.2019.06.16.03.12.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 16 Jun 2019 03:12:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of mikhail.v.gavrilov@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Sp0zNssZ;
       spf=pass (google.com: domain of mikhail.v.gavrilov@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mikhail.v.gavrilov@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=dXi83X39sc+SHqsRQb9qWakQ658qfuo/1ekg8hliBD0=;
        b=Sp0zNssZ3yGsTgfmNa9NkVGcWT/8Bn/SQOq3LUSy7KJSExWEAP4Qte5nb4jT/waLpA
         fx7Qiv9/fF+EuODR9/itkek4S1+dEGfgVBOpDm2wGAUXcueWeHHHgPI4wt0FQR5VbGM3
         AyMwUJQNqwZiviyReqLSvHBVMV1mh/d5rdKdeisQRDZUSdZ4rFT/LW2qAhZvHXEwpw56
         s+EyglpJMgN2kuq6581xB/X5hMUB6T61S385mK7WaOnmn8+oXbr+Xm7wGXu3S+gcCYpo
         VkTGDhLKQfwOkEo2pwG/g42CgANc4AAV4Oh+lIF1BMZ8YpnXxtsvU4mppO9esDH4g/1a
         HRzQ==
X-Google-Smtp-Source: APXvYqyUrK+C6uFyPu/mN+CP7kqloxH5tDYqAI6TJES117YkgWE/uPQUS7hB4tpeYLyAnmqD+FGwYyPPoXuvWiRvuYI=
X-Received: by 2002:a02:16c5:: with SMTP id a188mr78260707jaa.86.1560679967918;
 Sun, 16 Jun 2019 03:12:47 -0700 (PDT)
MIME-Version: 1.0
References: <CABXGCsN9mYmBD-4GaaeW_NrDu+FDXLzr_6x+XNxfmFV6QkYCDg@mail.gmail.com>
 <CABXGCsNq4xTFeeLeUXBj7vXBz55aVu31W9q74r+pGM83DrPjfA@mail.gmail.com>
 <20190529180931.GI18589@dhcp22.suse.cz> <CABXGCsPrk=WJzms_H+-KuwSRqWReRTCSs-GLMDsjUG_-neYP0w@mail.gmail.com>
In-Reply-To: <CABXGCsPrk=WJzms_H+-KuwSRqWReRTCSs-GLMDsjUG_-neYP0w@mail.gmail.com>
From: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
Date: Sun, 16 Jun 2019 15:12:37 +0500
Message-ID: <CABXGCsMjDn0VT0DmP6qeuiytce9cNBx8PywpqejiFNVhwd0UGg@mail.gmail.com>
Subject: Re: kernel BUG at mm/swap_state.c:170!
To: Michal Hocko <mhocko@kernel.org>
Cc: Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,
I finished today bisecting kernel.
And first bad commit for me was cd736d8b67fb22a85a68c1ee8020eb0d660615ec

Can you look into this?


$ git bisect log
git bisect start
# good: [a188339ca5a396acc588e5851ed7e19f66b0ebd9] Linux 5.2-rc1
git bisect good a188339ca5a396acc588e5851ed7e19f66b0ebd9
# good: [a188339ca5a396acc588e5851ed7e19f66b0ebd9] Linux 5.2-rc1
git bisect good a188339ca5a396acc588e5851ed7e19f66b0ebd9
# bad: [cd6c84d8f0cdc911df435bb075ba22ce3c605b07] Linux 5.2-rc2
git bisect bad cd6c84d8f0cdc911df435bb075ba22ce3c605b07
# bad: [060358de993f24562e884e265c4c57864a3a4141] treewide: Replace
GPLv2 boilerplate/reference with SPDX - rule 125
git bisect bad 060358de993f24562e884e265c4c57864a3a4141
# bad: [d53e860fd46f3d95c437bb67518f7374500de467] Merge branch 'linus'
of git://git.kernel.org/pub/scm/linux/kernel/git/herbert/crypto-2.6
git bisect bad d53e860fd46f3d95c437bb67518f7374500de467
# bad: [34dcf6a1902ac214149a2742250ff03aa5346f3e] net: caif: fix the
value of size argument of snprintf
git bisect bad 34dcf6a1902ac214149a2742250ff03aa5346f3e
# bad: [c7d5ec26ea4adf450d9ab2b794e7735761a93af1] Merge
git://git.kernel.org/pub/scm/linux/kernel/git/bpf/bpf
git bisect bad c7d5ec26ea4adf450d9ab2b794e7735761a93af1
# good: [3d21b6525caeae45f08e2d3a07ddfdef64882b8b] selftests/bpf: add
prog detach to flow_dissector test
git bisect good 3d21b6525caeae45f08e2d3a07ddfdef64882b8b
# bad: [3ebe1bca58c85325c97a22d4fc3f5b5420752e6f] ppp: deflate: Fix
possible crash in deflate_init
git bisect bad 3ebe1bca58c85325c97a22d4fc3f5b5420752e6f
# bad: [d0a7e8cb3c9d7d4fa2bcdd557be19f0841e2a3be] NFC: Orphan the subsystem
git bisect bad d0a7e8cb3c9d7d4fa2bcdd557be19f0841e2a3be
# bad: [0fe9f173d6cda95874edeb413b1fa9907b5ae830] net: Always descend into dsa/
git bisect bad 0fe9f173d6cda95874edeb413b1fa9907b5ae830
# bad: [cd736d8b67fb22a85a68c1ee8020eb0d660615ec] tcp: fix retrans
timestamp on passive Fast Open
git bisect bad cd736d8b67fb22a85a68c1ee8020eb0d660615ec
# first bad commit: [cd736d8b67fb22a85a68c1ee8020eb0d660615ec] tcp:
fix retrans timestamp on passive Fast Open



--
Best Regards,
Mike Gavrilov.

On Tue, 11 Jun 2019 at 08:59, Mikhail Gavrilov
<mikhail.v.gavrilov@gmail.com> wrote:
>
> On Wed, 29 May 2019 at 23:09, Michal Hocko <mhocko@kernel.org> wrote:
> >
> >
> > Do you see the same with 5.2-rc1 resp. 5.1?
>
> I can say with 100% certainty that kernel tag 5.1 is not affected by this bug.
>
> Say anything about 5.2 rc1 is very difficult because occurs another
> problem due to which all file systems are switched to read only mode.
>
> And I am sure that since 5.2 rc2 this issue is begin occurring.
>
> I also able recorded much more kernel logs with netconsole and option
> memblock=debug. (attached as file here)
>
> Please help me.


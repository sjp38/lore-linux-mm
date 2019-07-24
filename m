Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BBDADC76186
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 19:32:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 77F7121951
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 19:32:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="daangUid"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 77F7121951
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 24ABB6B0006; Wed, 24 Jul 2019 15:32:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1FB7A6B0007; Wed, 24 Jul 2019 15:32:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0C3FE6B0008; Wed, 24 Jul 2019 15:32:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id B3E246B0006
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 15:32:30 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id w25so30747869edu.11
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 12:32:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=RmmUOfw6KdNJB7Dw3A649BONg+TVcJuxBPKeIVpSw5Y=;
        b=qUJ+TSQPB2M7XusRrmbIzmnFS6vq6b8iYjtzzvgaB5K2JGuBgKux808vNXYq5BiYpF
         /fgCXPYHCPQHrPprxnBqt/iryOjHs9p3mS8jkfT2/4exIRwE/hSKa50BajCNb7U9XfB0
         d+8PgfwHQOiPjmv8tC1JWsW87YHogf7Ezv6FiSEfDnLBOGfkLwD+y1hTjIDHBwN77Qjt
         ZkWxJNktbA0YKxdAzZxDdJvt3Wvoch4Hhk1FnDUFmC14H37sjMU70CC65DZEwa/o9NwW
         CX6EHg/8Ugf1hFpf+Pde0tZxdVSl9uGzgJC2OB2mrHvGAbdf3n6e6YxDu7WHsooKt7wP
         IlvA==
X-Gm-Message-State: APjAAAVsHVtSyJ+Jf3C9bor9xI37nTaJvxG+UiG0ifE+6Q7XcPokimRT
	LdQgdLFCNv4RcctXeXDKlrUs/+6fZSXhv6is/E4wAKPyiK4V2XEEANK8tCQywBo/DKIlXa0pe3S
	W01yiN6Es6sVCAAMVHBlOMbVAQk5dPxd54Ry1gaLhAA7+Y5nWj4XRoSGUav3PdHMjjg==
X-Received: by 2002:a17:906:94ce:: with SMTP id d14mr65825773ejy.251.1563996750129;
        Wed, 24 Jul 2019 12:32:30 -0700 (PDT)
X-Received: by 2002:a17:906:94ce:: with SMTP id d14mr65825697ejy.251.1563996749125;
        Wed, 24 Jul 2019 12:32:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563996749; cv=none;
        d=google.com; s=arc-20160816;
        b=gEsfwLd2zFgChRiFZB/YsxoaYdKj22meRTq8CcZc9xSeZnxmhUf0fYezDCSJe/vzVb
         928wXqhfljpMMVHRxgdJrD+q+v9ob3i805Ov/17uYF5n2ZOnQ6ahlxCHDt6IzTfDv9Gw
         Lhk1f8bw0AkKFVvSgU8NMP370dqTlUVJdNe/KSA8SsXMRPxHworF099coJt/Nx3M93HT
         lWDV/EP/CIumKE9QglCFX8EKM0Ul5kuAr9yXik5ShfOtvc9r1DJ+LUtEsuL1DL57t6rx
         bSKvhmzjNHdLC08cLZL2iU5pYPlw+xXghnU+Y02v3rlkE2E8Do2kdL0m15N0WAxkRnE0
         jJ0w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=RmmUOfw6KdNJB7Dw3A649BONg+TVcJuxBPKeIVpSw5Y=;
        b=Sucmno3EvrXnfdBupnhIzmpm6VpjGZLrsTBjW9vwr0QnBEXWXS+U+/YZKELlcmtSeM
         TWT5LCY/NpNmGQO5z/CsO+oN2YMB0bvb+eaEo526kKwYQr3aeeWoF8vwjylc91JP9qF/
         zbw057U+DhkAQj+y7F41Y0Z3HIkYE5iJsFWjycMH/oG3UaPpJQ4dFr7ULgEU0nTQoAtq
         +x+Yc59aMfnpT0hd/dNpAbPAliCQVzjiRn6mnavtMpO2qWLsXDc9DOAEA1lIBqn++rqM
         esxRXLAnNlWvjIc7wAtsSObwRXZCneYR/lbifVgrS2bELUV39nYXO+tO6EKP1Nc97T0D
         0cPQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=daangUid;
       spf=pass (google.com: domain of matorola@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=matorola@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id no5sor11538815ejb.51.2019.07.24.12.32.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 24 Jul 2019 12:32:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of matorola@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=daangUid;
       spf=pass (google.com: domain of matorola@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=matorola@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=RmmUOfw6KdNJB7Dw3A649BONg+TVcJuxBPKeIVpSw5Y=;
        b=daangUidITkUVKr7vk3OUx08Gl1Jxg57OGBaW32/VfgcDYW4r8ueSaHlvl7prjeAAn
         6hbbOLWpvFqcVTCDWVzqtuonDNxTeBQ+SKsmAZa2QZG5GqbYinzXg9AQ78AarKMfpjje
         3IQG9AXksuIrunc2zx7/mlH6K0s4IGMvmxff7cHuLu5R8mGFv5U79S7o+KLdAHgA95Lr
         uN4yR1koyNq/sBo4AzrOFlpzNT0eZeoXLnzT7iCkJWsONrShxQpzSGGp7Us4+8mQ1sNf
         vIPKBtPZPxJUw3XWCA/roIuHPsq7vBfCJS3fZ69Vvb6pSNJKIcsFkES1O2U9mLRunOvz
         kkDA==
X-Google-Smtp-Source: APXvYqzQK3O5v+7yVlFJSGeU4C2I4d4sf8cRDv+2qxowZgzIVi2SvDX7ph8dKH/Lo5xszlodW3vLefHeISTmBsyrRKY=
X-Received: by 2002:a17:906:7f16:: with SMTP id d22mr64449323ejr.17.1563996748713;
 Wed, 24 Jul 2019 12:32:28 -0700 (PDT)
MIME-Version: 1.0
References: <20190625143715.1689-1-hch@lst.de> <20190625143715.1689-10-hch@lst.de>
 <20190717215956.GA30369@altlinux.org> <20190718.141405.1070121094691581998.davem@davemloft.net>
In-Reply-To: <20190718.141405.1070121094691581998.davem@davemloft.net>
From: Anatoly Pugachev <matorola@gmail.com>
Date: Wed, 24 Jul 2019 22:32:17 +0300
Message-ID: <CADxRZqx-jEnm4U8oe=tJf5apbvcMuw5OYZUN8h4G68sXFvDsmQ@mail.gmail.com>
Subject: Re: [PATCH 09/16] sparc64: use the generic get_user_pages_fast code
To: David Miller <davem@davemloft.net>
Cc: "Dmitry V. Levin" <ldv@altlinux.org>, Christoph Hellwig <hch@lst.de>, khalid.aziz@oracle.com, 
	torvalds@linux-foundation.org, akpm@linux-foundation.org, 
	Sparc kernel list <sparclinux@vger.kernel.org>, linux-mm@kvack.org, 
	Linux Kernel list <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jul 19, 2019 at 12:14 AM David Miller <davem@davemloft.net> wrote:
> > So this ended up as commit 7b9afb86b6328f10dc2cad9223d7def12d60e505
> > (thanks to Anatoly for bisecting) and introduced a regression:
> > futex.test from the strace test suite now causes an Oops on sparc64
> > in futex syscall.
> >
> > Here is a heavily stripped down reproducer:
>
> Does not reproduce for me on a T4-2 machine.
>
> So this problem might depend on the type of system you are on,
> I suspect it's one of those "pre-Niagara vs. Niagara and later"
> situations because that's the dividing line between two set of
> wildly different TLB and cache management methods.
>
> What kind of machine are you on?

David,

the first test where it was discovered was done on my test LDOM named
ttip, hardware (hypervisor) is T5-2 server, running under Solaris 11.4
OS.
ttip LDOM is debian sparc64 unstable , so with almost all the latest
software (gcc 8.3.0, binutils 2.32.51.20190707-1, debian GLIBC
2.28-10, etc..)

For another test, i also installed LDOM with oracle sparc linux
https://oss.oracle.com/projects/linux-sparc/ , but I've to install a
more fresh version of gcc on it first, since system installed gcc 4.4
is too old for a git kernel (linux-2.6/Documentation/Changes lists gcc
4.6 as a minimal version), so I choose to install gcc-7.4.0 to /opt/
(leaving system installed gcc 4.4 under /usr/bin). Compiled and
installed git kernel version, i.e. last tag 5.3.0-rc1 and ran the
test. Kernel still produced oops.


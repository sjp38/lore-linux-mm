Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_MED,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E907BC28CC7
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 09:25:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A44A227FE2
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 09:25:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="OMLIbGGF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A44A227FE2
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2B4966B026C; Mon,  3 Jun 2019 05:25:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 268286B026F; Mon,  3 Jun 2019 05:25:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 155726B0270; Mon,  3 Jun 2019 05:25:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f198.google.com (mail-vk1-f198.google.com [209.85.221.198])
	by kanga.kvack.org (Postfix) with ESMTP id E50FD6B026C
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 05:25:02 -0400 (EDT)
Received: by mail-vk1-f198.google.com with SMTP id q139so6314740vkq.23
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 02:25:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=w8FJ04SPncA3GGt4qcZJVbuvO4+vsSKpHoksXqQuYUI=;
        b=YL5OOuCzbvMn9yJn4n1FJ0cNMDsWvOM44/zWHkNJhWPjBolmsieiVqAe7kmdUhv4B3
         rQvcBeRCUd7HgIzgpwYEjNUQpWQjqskScV9xyD3UP6AT4YDpfMqcn/NmeNIbpAjzJG74
         dqnbAKj4BU8SjhUBYrz8Fr2Zdqh63fieMfKuf5UH27/bqzewYdsy1GwCeFWfy3wjbUzu
         Ok8rm3kh2D7bbl9kq/hQi+9Uim7uGW8smLJXunRt/lKGIaHVL3GEB9uA64YyBSAVZTS0
         vTg9s08Da+vothWmbJGc3P26Uk6SXIfjDHtyknYplAmjapEvJEZ+H7pkJIvx/3N+US59
         j03g==
X-Gm-Message-State: APjAAAWn3h+Wz9bjsHPrA/uVPjj1T38FJc7UVOCXc+huEXh03qHMiz2l
	Kv6o3+OEH2TYXzUXRwcfYO97ft+YCg2cRi5J9TL2NyqayT9JIP3y6H6joILfX/orhcjLNJRuq50
	i9Ndjm7xMozQumnPx5Sqxvpk0xfOZIgivRIUzdMKZQ/o9rjObgxcuqkg4extzgPwOKg==
X-Received: by 2002:a67:6d44:: with SMTP id i65mr12480051vsc.106.1559553902508;
        Mon, 03 Jun 2019 02:25:02 -0700 (PDT)
X-Received: by 2002:a67:6d44:: with SMTP id i65mr12480021vsc.106.1559553901709;
        Mon, 03 Jun 2019 02:25:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559553901; cv=none;
        d=google.com; s=arc-20160816;
        b=ctfO2AjZchAvcjALVWPY/sabEKEkLvFxD9DcAHcZQ7eMmEgVq/Riv7ybxFr3dOlJmf
         YvDoaMIO2SoMEflQXVrMSmk3iVKx8RzMY/rzd1ncGOF9YsHKvt6qAQP4iqEOKssPCt/o
         j5lD3FAMlyuwa1J0tBZHmVnpEGa4S+fVfLPROyKTmPCCd0YJkd2eJTLO+cil2zlsACT0
         rUXVPq/Sdu/pSrwIARnz4il3ejIA8o5ABxmS6nhRt0ebD/peyU1WyIpqQowy8Em5PgqC
         NCBlfhSszRd+Es9C43vCvf3IK7gzVn/wd+BzMMrRVr4/CLpkrNhn/qWE5ww4V2D9ZYC2
         VjMQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=w8FJ04SPncA3GGt4qcZJVbuvO4+vsSKpHoksXqQuYUI=;
        b=chlworzwVQrOqtYB7unPkXkKaSXzlPacdEiSZ+hOT+76l9QYZoLfwDCX3J2qoThuqk
         vqzY8dFCaMWZ9GeQ5SnVn/eLCw91A8PeiHICv0Gle5W/phyMnP/0eS6wEGBmAkMdlyzl
         tXClUle2cQdZvJpRuCquD+hbuapL7BYncrslb5x4TbrTBmG+UMcyvyj4nR3b4XNDCcQk
         uLOn6RDRusWTgziDdADWEt9ofxNEhE08zxxoOFWlQ0WNYE55sSYA8K3Ydt/IUD3qC4rJ
         3fYzrikH/nmEB1UPuX2ZNjQrq+7SfwzJiJaR0Shxp3gM0j36djt4TmByxDKLe8OXyJrs
         eEJw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=OMLIbGGF;
       spf=pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=glider@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t17sor6173700ual.16.2019.06.03.02.25.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 03 Jun 2019 02:25:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=OMLIbGGF;
       spf=pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=glider@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=w8FJ04SPncA3GGt4qcZJVbuvO4+vsSKpHoksXqQuYUI=;
        b=OMLIbGGF4iqU/3IBxXXOo51Z1Gh2iX+jT/XJanv3y/0Mlanl8zJA2fHTPptaNqwAy/
         wCPISvYJLg8glT89EOkSCGrUEwLbQNGSsPQB3xP0gjI7Qnoj9v/0iNfgM4mS6UVs1cdI
         ASiojU2tdAvCieLPAYfFUbKUwAx39XfYmeDORSJzdkuJ3vkYOm8FZf+sap+UctIi5Inl
         AgNqY79mVOQvJbxNLvSndWErvOsmI5+gxjsaG/j0cl6rh4ldiKUw56A3oejSuCOFbFTv
         5Lkaj44XlpdgfkLJZbb89pa8zO7s4vqoneWdvi7fIrUzKI7kgDAV+syf1sGfWPpsVjG/
         PAzw==
X-Google-Smtp-Source: APXvYqyh6QlCEo0EU+R0uj2OfHoB0V/HJYqXE1klW7h8DXFh/JtB716lws+dopD6Xp86RJPH8UG3RqT+AAiUP3DAyxA=
X-Received: by 2002:ab0:c11:: with SMTP id a17mr8422532uak.3.1559553901030;
 Mon, 03 Jun 2019 02:25:01 -0700 (PDT)
MIME-Version: 1.0
References: <20190529123812.43089-1-glider@google.com> <20190529123812.43089-3-glider@google.com>
 <20190531181832.e7c3888870ce9e50db9f69e6@linux-foundation.org>
In-Reply-To: <20190531181832.e7c3888870ce9e50db9f69e6@linux-foundation.org>
From: Alexander Potapenko <glider@google.com>
Date: Mon, 3 Jun 2019 11:24:49 +0200
Message-ID: <CAG_fn=XBq-ipvZng3hEiGwyQH2rRNFbN_Cj0r+5VoJqou0vovA@mail.gmail.com>
Subject: Re: [PATCH v5 2/3] mm: init: report memory auto-initialization
 features at boot time
To: Andrew Morton <akpm@linux-foundation.org>, Kees Cook <keescook@chromium.org>
Cc: Christoph Lameter <cl@linux.com>, Dmitry Vyukov <dvyukov@google.com>, James Morris <jmorris@namei.org>, 
	Jann Horn <jannh@google.com>, Kostya Serebryany <kcc@google.com>, Laura Abbott <labbott@redhat.com>, 
	Mark Rutland <mark.rutland@arm.com>, Masahiro Yamada <yamada.masahiro@socionext.com>, 
	Matthew Wilcox <willy@infradead.org>, Nick Desaulniers <ndesaulniers@google.com>, 
	Randy Dunlap <rdunlap@infradead.org>, Sandeep Patil <sspatil@android.com>, 
	"Serge E. Hallyn" <serge@hallyn.com>, Souptick Joarder <jrdr.linux@gmail.com>, Marco Elver <elver@google.com>, 
	Kernel Hardening <kernel-hardening@lists.openwall.com>, 
	Linux Memory Management List <linux-mm@kvack.org>, 
	linux-security-module <linux-security-module@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Jun 1, 2019 at 3:18 AM Andrew Morton <akpm@linux-foundation.org> wr=
ote:
>
> On Wed, 29 May 2019 14:38:11 +0200 Alexander Potapenko <glider@google.com=
> wrote:
>
> > Print the currently enabled stack and heap initialization modes.
> >
> > The possible options for stack are:
> >  - "all" for CONFIG_INIT_STACK_ALL;
> >  - "byref_all" for CONFIG_GCC_PLUGIN_STRUCTLEAK_BYREF_ALL;
> >  - "byref" for CONFIG_GCC_PLUGIN_STRUCTLEAK_BYREF;
> >  - "__user" for CONFIG_GCC_PLUGIN_STRUCTLEAK_USER;
> >  - "off" otherwise.
> >
> > Depending on the values of init_on_alloc and init_on_free boottime
> > options we also report "heap alloc" and "heap free" as "on"/"off".
>
> Why?
>
> Please fully describe the benefit to users so that others can judge the
> desirability of the patch.  And so they can review it effectively, etc.
I'm going to update the description with the following passage:

    Print the currently enabled stack and heap initialization modes.

    Stack initialization is enabled by a config flag, while heap
    initialization is configured at boot time with defaults being set
    in the config. It's more convenient for the user to have all informatio=
n
    about these hardening measures in one place.

Does this make sense?
> Always!
>
> > In the init_on_free mode initializing pages at boot time may take some
> > time, so print a notice about that as well.
>
> How much time?
I've seen pauses up to 1 second, not actually sure they're worth a
separate line in the log.
Kees, how long were the delays in your case?



--=20
Alexander Potapenko
Software Engineer

Google Germany GmbH
Erika-Mann-Stra=C3=9Fe, 33
80636 M=C3=BCnchen

Gesch=C3=A4ftsf=C3=BChrer: Paul Manicle, Halimah DeLaine Prado
Registergericht und -nummer: Hamburg, HRB 86891
Sitz der Gesellschaft: Hamburg


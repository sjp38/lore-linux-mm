Return-Path: <SRS0=9Pd6=UE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AA70EC28CC3
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 02:59:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 52D1720717
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 02:59:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 52D1720717
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=kaiwantech.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B444F6B0266; Tue,  4 Jun 2019 22:59:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AF6996B0269; Tue,  4 Jun 2019 22:59:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9E4EF6B026A; Tue,  4 Jun 2019 22:59:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6577A6B0266
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 22:59:06 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id d7so13812774pgc.8
        for <linux-mm@kvack.org>; Tue, 04 Jun 2019 19:59:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :references:in-reply-to:from:date:message-id:subject:to:cc;
        bh=QATEyUJl7/R8rsMta/IvCxJc2I3S1C2nTlhtU+utHqM=;
        b=XaYjb6983EWDx1aUpVRN2HXkwr6Hojw2KJj22oiLvQ2arg+/9qUzDM6pR0d6JFTmKB
         YSnUorWvHb7kDTRNnDW0HrAFeGebu7enUjBN+p4l7wMdVOIGR1gv6ajmRZjv3lTSEiLh
         XqNQ0qGeafb3f5r8uVm8xj7Mshp4/9mRV26ITHUob8JTxnzf7SDAfUZqfvSpGlEm10qn
         fsdRpJ02NEhl71NemyLsEsIqXVgVg0yeHbjUijMba6pMqm1BMQQ40nm4sMlZChR5+9ef
         F10gO2+ZuYjVnNbnjXSYiMh+LkIteXAZ1Kn/0vIxg0Ay8qa0rXiIsVkpokug4/5OyjdZ
         ye9A==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 182.50.145.5 is neither permitted nor denied by best guess record for domain of kaiwan@kaiwantech.com) smtp.mailfrom=kaiwan@kaiwantech.com
X-Gm-Message-State: APjAAAXdW4hwlyJ7DBbMVDSpJaLM9j0Bdh52byh4YG4WhOb/5Fq7YPWn
	KV9hzcbgZ8hkEoKfl3YqXj0QkW7z6dGrxe0r7NkhhMv4eye8gUIU78gGz1HNpOj37MIYApN3Q7O
	ntPYZAy+zn/2xHTFz8tO6ARKgSBLmS2MiaVpO8umnCnlSZ3p3kB2r77QMHYVNREI=
X-Received: by 2002:a65:5344:: with SMTP id w4mr1098853pgr.8.1559703546046;
        Tue, 04 Jun 2019 19:59:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwEnRYSFSk/nPJaBBndYT2LqBF8ceuKy32jHjs0HAxSVnGidviNKKJKHgOiDHDvZtBe8dgb
X-Received: by 2002:a65:5344:: with SMTP id w4mr1098817pgr.8.1559703545285;
        Tue, 04 Jun 2019 19:59:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559703545; cv=none;
        d=google.com; s=arc-20160816;
        b=uI+tWf/TgSmoPweaa9sGOu2+OMiSOGUWxWd7ydedYNkjFr7jDk3T/Ir36ROzpuFOKa
         VisOv7joE0EVhUwromCfCEbikxVL6amTdlJESWptWb6byn+CC3aH2ZrHfq1+id8BbBEX
         T9AYxprMwPvJKxIQWVjSAbUzYMOvTDlMCg4TtZ4h0JI6jX64Ot55sGGYSgw4NieW5zSX
         w+p3oA98x7jZSaxU6vvKmGnV1fkdp421wmnIXESEstguwE7WQOG6VVB/syse7DftzOkD
         uWixiQP24WKMQ92DOjBuY/NBuLQEqzwgxykvSlSKU0QVpJYm7io3tbglsdfjKMw4Qwxh
         vRjw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version;
        bh=QATEyUJl7/R8rsMta/IvCxJc2I3S1C2nTlhtU+utHqM=;
        b=o4uaihbkCGGtGCJne/d3E1grLx2UEMy6WnzHtVdRjiax4sgJMLAdQxLxwvckx40dls
         PGTWhygCj4VWvtl7u9/tJ82UbHiMttnc989aqesA12MYzWGG3iq7Xx9KPG4kvkwdPK6w
         Tw7hyzs3tti0DrzUVfa63P8KMcSvTq1Sqxu3iE5xIRLk9IrvdCWaPGS0WOJu9uuyOWaH
         ZX1NvqOtvVgnqKSmmArP90JMMjP5gllES0A0tD4Q7kRpO8IaPMVuBxvvpV5aqNvnrHkb
         txcSmLWuXzevybqML5yBwlPfcsWtn2lXMxZ9Fr8O4fcL8LRK6YACdR6HIWquTRzQ3bVh
         +xHw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 182.50.145.5 is neither permitted nor denied by best guess record for domain of kaiwan@kaiwantech.com) smtp.mailfrom=kaiwan@kaiwantech.com
Received: from sg2plout10-02.prod.sin2.secureserver.net (sg2plout10-02.prod.sin2.secureserver.net. [182.50.145.5])
        by mx.google.com with ESMTPS id x1si7148771pfa.253.2019.06.04.19.59.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Jun 2019 19:59:05 -0700 (PDT)
Received-SPF: neutral (google.com: 182.50.145.5 is neither permitted nor denied by best guess record for domain of kaiwan@kaiwantech.com) client-ip=182.50.145.5;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 182.50.145.5 is neither permitted nor denied by best guess record for domain of kaiwan@kaiwantech.com) smtp.mailfrom=kaiwan@kaiwantech.com
Received: from mail-qk1-f171.google.com ([209.85.222.171])
	by :SMTPAUTH: with ESMTPSA
	id YM8ihd5EBitkDYM8lhjA5G; Tue, 04 Jun 2019 19:59:04 -0700
Received: by mail-qk1-f171.google.com with SMTP id r6so4286397qkc.0
        for <linux-mm@kvack.org>; Tue, 04 Jun 2019 19:59:03 -0700 (PDT)
X-Received: by 2002:a37:68ca:: with SMTP id d193mr19119973qkc.240.1559703540328;
 Tue, 04 Jun 2019 19:59:00 -0700 (PDT)
MIME-Version: 1.0
References: <20190529123812.43089-1-glider@google.com> <20190529123812.43089-3-glider@google.com>
 <20190531181832.e7c3888870ce9e50db9f69e6@linux-foundation.org>
 <CAG_fn=XBq-ipvZng3hEiGwyQH2rRNFbN_Cj0r+5VoJqou0vovA@mail.gmail.com>
 <201906032010.8E630B7@keescook> <CAPDLWs-JqUx+_sDtsER=keDu9o2NKYQ3mvZVXLY8deXOMZoH=g@mail.gmail.com>
 <CAG_fn=UxfaFVZbtnO0VefKhi3iZUYn5ybe_Nvo0rCOxxA2nn-Q@mail.gmail.com>
In-Reply-To: <CAG_fn=UxfaFVZbtnO0VefKhi3iZUYn5ybe_Nvo0rCOxxA2nn-Q@mail.gmail.com>
From: Kaiwan N Billimoria <kaiwan@kaiwantech.com>
Date: Wed, 5 Jun 2019 08:28:43 +0530
X-Gmail-Original-Message-ID: <CAPDLWs__StRJ3AwXNDL3D=_nEkzB_Hto+8+55V=npw63R6_SMQ@mail.gmail.com>
Message-ID: <CAPDLWs__StRJ3AwXNDL3D=_nEkzB_Hto+8+55V=npw63R6_SMQ@mail.gmail.com>
Subject: Re: [PATCH v5 2/3] mm: init: report memory auto-initialization
 features at boot time
To: Alexander Potapenko <glider@google.com>
Cc: Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Christoph Lameter <cl@linux.com>, Dmitry Vyukov <dvyukov@google.com>, James Morris <jmorris@namei.org>, 
	Jann Horn <jannh@google.com>, Kostya Serebryany <kcc@google.com>, Laura Abbott <labbott@redhat.com>, 
	Mark Rutland <mark.rutland@arm.com>, Masahiro Yamada <yamada.masahiro@socionext.com>, 
	Matthew Wilcox <willy@infradead.org>, Nick Desaulniers <ndesaulniers@google.com>, 
	Randy Dunlap <rdunlap@infradead.org>, Sandeep Patil <sspatil@android.com>, 
	"Serge E. Hallyn" <serge@hallyn.com>, Souptick Joarder <jrdr.linux@gmail.com>, Marco Elver <elver@google.com>, 
	Kernel Hardening <kernel-hardening@lists.openwall.com>, 
	Linux Memory Management List <linux-mm@kvack.org>, 
	linux-security-module <linux-security-module@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-CMAE-Envelope: MS4wfM4dP3S5j61pW2Lhlvmiq5WbxtJZ5guAzup9NG5aJdgiKoBTCMbNr2omAwlwk6f17FFTDUPKFkpoTKVb3UKjzACd3c1NjtH4dtHRC0yHBlGsB3moCVnT
 rANp4lMJPnU+UBevg6sdRO0fDX2mv/16sFKKOD1L+rrLMRX5FYqsIkAgM4mbGnWx/MQW0PfCBNi6LQ==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 4, 2019 at 8:36 PM Alexander Potapenko <glider@google.com> wrote:
>
> On Tue, Jun 4, 2019 at 8:01 AM Kaiwan N Billimoria
> <kaiwan@kaiwantech.com> wrote:
> >
> > On Tue, Jun 4, 2019 at 8:44 AM Kees Cook <keescook@chromium.org> wrote:
> > >
> > > On Mon, Jun 03, 2019 at 11:24:49AM +0200, Alexander Potapenko wrote:
> > > > On Sat, Jun 1, 2019 at 3:18 AM Andrew Morton <akpm@linux-foundation.org> wrote:
> > > > >
> > > > > On Wed, 29 May 2019 14:38:11 +0200 Alexander Potapenko <glider@google.com> wrote:
> > > > >
> > > > > > Print the currently enabled stack and heap initialization modes.
> > > > > >
> > > > > > The possible options for stack are:
> > > > > >  - "all" for CONFIG_INIT_STACK_ALL;
> > > > > >  - "byref_all" for CONFIG_GCC_PLUGIN_STRUCTLEAK_BYREF_ALL;
> > > > > >  - "byref" for CONFIG_GCC_PLUGIN_STRUCTLEAK_BYREF;
> > > > > >  - "__user" for CONFIG_GCC_PLUGIN_STRUCTLEAK_USER;
> > > > > >  - "off" otherwise.
> > > > > >
> > > > > > Depending on the values of init_on_alloc and init_on_free boottime
> > > > > > options we also report "heap alloc" and "heap free" as "on"/"off".
> > > > >
> > > > > Why?
> > > > >
> > > > > Please fully describe the benefit to users so that others can judge the
> > > > > desirability of the patch.  And so they can review it effectively, etc.
> > > > I'm going to update the description with the following passage:
> > > >
> > > >     Print the currently enabled stack and heap initialization modes.
> > > >
> > > >     Stack initialization is enabled by a config flag, while heap
> > > >     initialization is configured at boot time with defaults being set
> > > >     in the config. It's more convenient for the user to have all information
> > > >     about these hardening measures in one place.
> > > >
> > > > Does this make sense?
> > > > > Always!
> > > > >
> > > > > > In the init_on_free mode initializing pages at boot time may take some
> > > > > > time, so print a notice about that as well.
> > > > >
> > > > > How much time?
> > > > I've seen pauses up to 1 second, not actually sure they're worth a
> > > > separate line in the log.
> > > > Kees, how long were the delays in your case?
> > >
> > > I didn't measure it, but I think it was something like 0.5 second per GB.
> > > I noticed because normally boot flashes by. With init_on_free it pauses
> > > for no apparent reason, which is why I suggested the note. (I mean *I*
> > > knew why it was pausing, but it might surprise someone who sets
> > > init_on_free=1 without really thinking about what's about to happen at
> > > boot.)
> >
> > (Pardon the gmail client)
> > How about:
> > - if (want_init_on_free())
> > -               pr_info("Clearing system memory may take some time...\n");
> > +  if (want_init_on_free())
> > +              pr_info("meminit: clearing system memory may take some
> > time...\n");
> Yes, adding a prefix may give the users better understanding of who's
> clearing the memory.
> We should stick to the same prefix as before though, i.e. "mem auto-init"

True, agreed.
--
Kaiwan


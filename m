Return-Path: <SRS0=7ZCb=UD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ACAE2C28CC6
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 06:01:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4EF0924484
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 06:01:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4EF0924484
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=kaiwantech.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A60976B000D; Tue,  4 Jun 2019 02:01:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A10D16B0010; Tue,  4 Jun 2019 02:01:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 900246B0266; Tue,  4 Jun 2019 02:01:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 55C136B000D
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 02:01:50 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id w14so13321241plp.4
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 23:01:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :references:in-reply-to:from:date:message-id:subject:to:cc;
        bh=GCQmtv7FhlouA8M5jSS3Ut+JA2Yr+XuxOxirrogHYP4=;
        b=rYyvbrucrImjsc9KdL/HkigGtXwFdAQ6XNJ/DgxICm+M3Q+ZjN+fwIk+XDE4IVnnFF
         1lmWqkldsHLVgFvKSf4dBWJgTR2QrxkbfzV/BFoGTRwx/3vpDb9FK+LkRAjq1Kq2YQuZ
         dm8hp9fvSv7VveuY/3UjS4nH7QNfoQ0+57XbqxaJH68+yvAjmMXAUNiozLz8RFGfjMG0
         fIk9SCURGNYEYXCDAQ17hUNjUikVTK1WtlUV+SIPjWe4VlAtz7Oyvq91252eFtEkomoh
         qF/F96T4sYuSnBmdxyU8asyAJn+ZSuAzt31ewwbpTkF+kqmmlpCqh3w9woKuUzD7Oq7q
         tA7A==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 182.50.145.5 is neither permitted nor denied by best guess record for domain of kaiwan@kaiwantech.com) smtp.mailfrom=kaiwan@kaiwantech.com
X-Gm-Message-State: APjAAAWhovf5pvkwkjB49OcmjPcs5KiSN4PCIRMCBB67lfkzU3tFRB6q
	TxI6kGmFFKozfS2YAG33FCDqaDmHD3Tt8ggcJSlNIZy9dNIw9+ycblFx50YMFf8eUbf7YXYXO7Z
	d2UeB6+w8eBxi0B8rvfC8KFrp573iJIpKVBd0rqEE4Rsc3lPY5GT3YewWoNp3f8k=
X-Received: by 2002:a65:4c4c:: with SMTP id l12mr24189920pgr.404.1559628109880;
        Mon, 03 Jun 2019 23:01:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzSBGGX2V2OzNZSY0lyGqVJ28P5q8C1gTGpyeN42LZoEvsZlz2LIOjmo2JDrw97zdgauDQA
X-Received: by 2002:a65:4c4c:: with SMTP id l12mr24189868pgr.404.1559628108940;
        Mon, 03 Jun 2019 23:01:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559628108; cv=none;
        d=google.com; s=arc-20160816;
        b=eDdfXWPdRWZhy7RPiGDGh43Y8xo089trR2zkBdSIpL0JiqJA9SixhHRpw25580vaNa
         RwPVzsu/mkiWQhf7QmzITCouF/IOp6mGzBGOd7FKsPUDZhCvL0CB+Gn3tJGg00M+SSbj
         EFWuDK8Ydj9OPUNWgLj+w85jWoilv6HbpjUiCGyHWi6j7o5qhfsheIR8Db9p5XVx7Z0a
         6DkbL4LbkFAVLMmt1H2FHoLd3DUSiAYuYJajASWG1fMw210ZQOeeb0vIwk9c0ftBDwSH
         3pzpeiDWy77b/W4AW5o2hswNHeFu0WjwS+0c0vq+rBuvxkD8dv/HDP0ObLK25/Q2Us+7
         IrzA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version;
        bh=GCQmtv7FhlouA8M5jSS3Ut+JA2Yr+XuxOxirrogHYP4=;
        b=S1rM24lQb8HkWvu/WX/Yc8MwLCBblFB29i+ROoipFb2y/kyI591WWzDDfpN/iQg2h+
         U29T3UbQuOi7hk8fI2KmFdHzIG4bkTOA6Iv2V9WnWLKv/wYzeQ71dtkP7NDA/tK3hJXu
         M3l+fIx6AxrNcTlMEcAet0paw7086kt7rpIvo5edg9F9GSj5LCSUr71ARV9Q+ftgYhpk
         VeUj6cpxKxJB7Z+pYKUwP2q5LT7dkUJWwoCpH/44wyZXEj0VJbvJipgcaI2d+dbFmlEw
         5PZl9AUvw6/Yo88bPa/gWZ0ogdREAugG65Kkq0CUTWULmbh+WHmxnwsW65GamvetAV5T
         8yxQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 182.50.145.5 is neither permitted nor denied by best guess record for domain of kaiwan@kaiwantech.com) smtp.mailfrom=kaiwan@kaiwantech.com
Received: from sg2plout10-02.prod.sin2.secureserver.net (sg2plout10-02.prod.sin2.secureserver.net. [182.50.145.5])
        by mx.google.com with ESMTPS id g1si1300579pfi.249.2019.06.03.23.01.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Jun 2019 23:01:48 -0700 (PDT)
Received-SPF: neutral (google.com: 182.50.145.5 is neither permitted nor denied by best guess record for domain of kaiwan@kaiwantech.com) client-ip=182.50.145.5;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 182.50.145.5 is neither permitted nor denied by best guess record for domain of kaiwan@kaiwantech.com) smtp.mailfrom=kaiwan@kaiwantech.com
Received: from mail-qk1-f171.google.com ([209.85.222.171])
	by :SMTPAUTH: with ESMTPSA
	id Y2VzhZHJDitkDY2W2hhnfc; Mon, 03 Jun 2019 23:01:47 -0700
Received: by mail-qk1-f171.google.com with SMTP id d15so2081326qkl.4
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 23:01:46 -0700 (PDT)
X-Received: by 2002:a37:7786:: with SMTP id s128mr25455055qkc.63.1559628103055;
 Mon, 03 Jun 2019 23:01:43 -0700 (PDT)
MIME-Version: 1.0
References: <20190529123812.43089-1-glider@google.com> <20190529123812.43089-3-glider@google.com>
 <20190531181832.e7c3888870ce9e50db9f69e6@linux-foundation.org>
 <CAG_fn=XBq-ipvZng3hEiGwyQH2rRNFbN_Cj0r+5VoJqou0vovA@mail.gmail.com> <201906032010.8E630B7@keescook>
In-Reply-To: <201906032010.8E630B7@keescook>
From: Kaiwan N Billimoria <kaiwan@kaiwantech.com>
Date: Tue, 4 Jun 2019 11:31:26 +0530
X-Gmail-Original-Message-ID: <CAPDLWs-JqUx+_sDtsER=keDu9o2NKYQ3mvZVXLY8deXOMZoH=g@mail.gmail.com>
Message-ID: <CAPDLWs-JqUx+_sDtsER=keDu9o2NKYQ3mvZVXLY8deXOMZoH=g@mail.gmail.com>
Subject: Re: [PATCH v5 2/3] mm: init: report memory auto-initialization
 features at boot time
To: Kees Cook <keescook@chromium.org>
Cc: Alexander Potapenko <glider@google.com>, Andrew Morton <akpm@linux-foundation.org>, 
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
X-CMAE-Envelope: MS4wfKuwuYVUPi1IRrogxfgSztB3pc9BnAIzWlK+L+hi0J88PuKrUf46Y0iKrl9TviHNkHPCXp8b7VDi9WJ3Hkpaz0NE0IfAd1MNDDB/8x2kIfihGUJvV9XR
 44hvgIhDlqgpZUFXKTyyoeEtXb6XWx2BF3PVM66q7COExRrFMNPL+Dv5iVmWbcC4d9RYsZZCXyfjgQ==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 4, 2019 at 8:44 AM Kees Cook <keescook@chromium.org> wrote:
>
> On Mon, Jun 03, 2019 at 11:24:49AM +0200, Alexander Potapenko wrote:
> > On Sat, Jun 1, 2019 at 3:18 AM Andrew Morton <akpm@linux-foundation.org> wrote:
> > >
> > > On Wed, 29 May 2019 14:38:11 +0200 Alexander Potapenko <glider@google.com> wrote:
> > >
> > > > Print the currently enabled stack and heap initialization modes.
> > > >
> > > > The possible options for stack are:
> > > >  - "all" for CONFIG_INIT_STACK_ALL;
> > > >  - "byref_all" for CONFIG_GCC_PLUGIN_STRUCTLEAK_BYREF_ALL;
> > > >  - "byref" for CONFIG_GCC_PLUGIN_STRUCTLEAK_BYREF;
> > > >  - "__user" for CONFIG_GCC_PLUGIN_STRUCTLEAK_USER;
> > > >  - "off" otherwise.
> > > >
> > > > Depending on the values of init_on_alloc and init_on_free boottime
> > > > options we also report "heap alloc" and "heap free" as "on"/"off".
> > >
> > > Why?
> > >
> > > Please fully describe the benefit to users so that others can judge the
> > > desirability of the patch.  And so they can review it effectively, etc.
> > I'm going to update the description with the following passage:
> >
> >     Print the currently enabled stack and heap initialization modes.
> >
> >     Stack initialization is enabled by a config flag, while heap
> >     initialization is configured at boot time with defaults being set
> >     in the config. It's more convenient for the user to have all information
> >     about these hardening measures in one place.
> >
> > Does this make sense?
> > > Always!
> > >
> > > > In the init_on_free mode initializing pages at boot time may take some
> > > > time, so print a notice about that as well.
> > >
> > > How much time?
> > I've seen pauses up to 1 second, not actually sure they're worth a
> > separate line in the log.
> > Kees, how long were the delays in your case?
>
> I didn't measure it, but I think it was something like 0.5 second per GB.
> I noticed because normally boot flashes by. With init_on_free it pauses
> for no apparent reason, which is why I suggested the note. (I mean *I*
> knew why it was pausing, but it might surprise someone who sets
> init_on_free=1 without really thinking about what's about to happen at
> boot.)

(Pardon the gmail client)
How about:
- if (want_init_on_free())
-               pr_info("Clearing system memory may take some time...\n");
+  if (want_init_on_free())
+              pr_info("meminit: clearing system memory may take some
time...\n");

or even

+ if (want_init_on_free())
+                pr_info("meminit (init_on_free == 1): clearing system
memory may take some time...\n");

or some combo thereof?

--
Kaiwan
>
> --
> Kees Cook
>


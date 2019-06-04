Return-Path: <SRS0=7ZCb=UD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_HIGH autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8432CC04AB5
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 03:14:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2EA442425F
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 03:14:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="O7cjrefY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2EA442425F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 75BE26B000D; Mon,  3 Jun 2019 23:14:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6E4E86B0010; Mon,  3 Jun 2019 23:14:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5AC616B0266; Mon,  3 Jun 2019 23:14:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2108F6B000D
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 23:14:11 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id 93so13071782plf.14
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 20:14:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to;
        bh=c5HP5Me6K1D1zdUUO0f7kzVFOIQyYSbiNswjCmfwwdM=;
        b=Bje2p6dAtatOyFD7v5T1urXe6Ce42zMbMx3vtUZplYaZPOCtZ1GK99dJRKiA46g7wC
         8PXQwEsaaFeeilzZYMJaFyfja+LfnqUMELgNYpRfo1YQOxTKhOJzdoi31/HIH+vRIAeL
         1t79RNwQytYEjokHRCMWR47vgmupDv7nAkq94korUrnYwj2gEICHSP2g8WyovwT6r0GZ
         iU6/z8uVUEWylP42Jjr+iMs2/+brq6wc6MKXnJtf4jdFsyaYlfLlqL6oxOuISP7FZl0l
         JT35SFRyFJUJSXln8PFDCR3vwN0gx22kCMkfwcJDwd9UmBQcHbzK9NDA/wC9wQ10lJNG
         h2hA==
X-Gm-Message-State: APjAAAU+yMXABSGaytg9bT63KA8V7Jtr3siats1ihUZ4FwBIWFVRa57i
	MvlVNf3TMdrhsWQRV13ZGQJqeQyu/mBTKNkg1DA15jn+9RkzQWHyABIDdFJcp3BxFyDBayq6oh3
	xIs9BWLtJfvtPD0XyarC/rC5Y+Xqt9kOdgYzxMxC1XQMbJaM0zT6V9i3W5Mh2zhsPhQ==
X-Received: by 2002:a62:b40a:: with SMTP id h10mr36065307pfn.216.1559618050612;
        Mon, 03 Jun 2019 20:14:10 -0700 (PDT)
X-Received: by 2002:a62:b40a:: with SMTP id h10mr36065243pfn.216.1559618049403;
        Mon, 03 Jun 2019 20:14:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559618049; cv=none;
        d=google.com; s=arc-20160816;
        b=dCxSkubabDWGTxNxt5nId8Z7j0MxRR+N/merYOpOKK+xcPASZTINGFDkv3J1m0U/VZ
         ajmUGC0lHcthSqFysqyBDFgfYveNjpA5AKGlZVM8KCwgvnPs0+/Rvcwd6nqgnolWAgqZ
         3NKIITpLpjToZC4ogcQbeWs7+opg2tF7kyV6VAgoQVneykCL8vGrO/iwgJd93w5vdar0
         nmYr4TbHthEP7O0EaIWZLwEIiYvJ5aGfyock0E6ZmtoKelGhA6VzdD88KWa0kHIC4hyS
         0a2/6QGdW7KSODaRljI/kG/V58SCjbSmpNILc8qKMaP/6xdDGsSY9P1tCNwMszLCfHM8
         uh8g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date:dkim-signature;
        bh=c5HP5Me6K1D1zdUUO0f7kzVFOIQyYSbiNswjCmfwwdM=;
        b=rkhG/3jHIdmS90cP3yIo+eSH2mC41OxIsGT1SWahzTBfwst2T2n0D1YFev8fkFyJvb
         tjHnraWSbJpNV4eg7qu96u2WV3Ow1Y2WFVu/U/G204QyLIMbCrNuAXSI0+oixnlYD5V+
         nVDolkySYos8MCx9UOkYjfz7YiHcYTRtLKGeJkK4ejA2lL/dgZCH14DxXU5qpz4bCYFR
         gi4Z68o/6YCAQ+3+txPc1ZiVRv+aURqH/LPUUVL8DXFH3ZbEYdPPDg6dz+30m+tctRae
         ZQ00XzpVSWt5Ur6ME6sAg2QhgI8t0nKKCEznFlViCkGhSP4fowJ0w17RDTLHrm6njqMC
         W2fw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=O7cjrefY;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q6sor19069425pjp.1.2019.06.03.20.14.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 03 Jun 2019 20:14:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=O7cjrefY;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to;
        bh=c5HP5Me6K1D1zdUUO0f7kzVFOIQyYSbiNswjCmfwwdM=;
        b=O7cjrefYDb8qdY6xHlr7GQJ9p1Q5FyScv3e2w+vscGV9dmLj3ZLW9f5Pf+78Vl8cuW
         0jy0uX2DCPP14kq0gZIICMmiy5PCkk1FdQ8qsJt5mI6MDzj6VECvJfWif7Wo3c2QjgSS
         u7igduXfvXL5/BBTot/FruOSt3YvXQO0ax1VM=
X-Google-Smtp-Source: APXvYqyr65yqSMgjUZyLKXrBeCQLIR7WRh1PgCOxNwDSym495N0oGFV/Y355onNEh2hWQW9f50Nt2g==
X-Received: by 2002:a17:90a:35c:: with SMTP id 28mr33030091pjf.110.1559618048938;
        Mon, 03 Jun 2019 20:14:08 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
        by smtp.gmail.com with ESMTPSA id v4sm3118023pfb.14.2019.06.03.20.14.07
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 03 Jun 2019 20:14:07 -0700 (PDT)
Date: Mon, 3 Jun 2019 20:14:06 -0700
From: Kees Cook <keescook@chromium.org>
To: Alexander Potapenko <glider@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Christoph Lameter <cl@linux.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	James Morris <jmorris@namei.org>, Jann Horn <jannh@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Laura Abbott <labbott@redhat.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Masahiro Yamada <yamada.masahiro@socionext.com>,
	Matthew Wilcox <willy@infradead.org>,
	Nick Desaulniers <ndesaulniers@google.com>,
	Randy Dunlap <rdunlap@infradead.org>,
	Sandeep Patil <sspatil@android.com>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Souptick Joarder <jrdr.linux@gmail.com>,
	Marco Elver <elver@google.com>,
	Kernel Hardening <kernel-hardening@lists.openwall.com>,
	Linux Memory Management List <linux-mm@kvack.org>,
	linux-security-module <linux-security-module@vger.kernel.org>
Subject: Re: [PATCH v5 2/3] mm: init: report memory auto-initialization
 features at boot time
Message-ID: <201906032010.8E630B7@keescook>
References: <20190529123812.43089-1-glider@google.com>
 <20190529123812.43089-3-glider@google.com>
 <20190531181832.e7c3888870ce9e50db9f69e6@linux-foundation.org>
 <CAG_fn=XBq-ipvZng3hEiGwyQH2rRNFbN_Cj0r+5VoJqou0vovA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAG_fn=XBq-ipvZng3hEiGwyQH2rRNFbN_Cj0r+5VoJqou0vovA@mail.gmail.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 03, 2019 at 11:24:49AM +0200, Alexander Potapenko wrote:
> On Sat, Jun 1, 2019 at 3:18 AM Andrew Morton <akpm@linux-foundation.org> wrote:
> >
> > On Wed, 29 May 2019 14:38:11 +0200 Alexander Potapenko <glider@google.com> wrote:
> >
> > > Print the currently enabled stack and heap initialization modes.
> > >
> > > The possible options for stack are:
> > >  - "all" for CONFIG_INIT_STACK_ALL;
> > >  - "byref_all" for CONFIG_GCC_PLUGIN_STRUCTLEAK_BYREF_ALL;
> > >  - "byref" for CONFIG_GCC_PLUGIN_STRUCTLEAK_BYREF;
> > >  - "__user" for CONFIG_GCC_PLUGIN_STRUCTLEAK_USER;
> > >  - "off" otherwise.
> > >
> > > Depending on the values of init_on_alloc and init_on_free boottime
> > > options we also report "heap alloc" and "heap free" as "on"/"off".
> >
> > Why?
> >
> > Please fully describe the benefit to users so that others can judge the
> > desirability of the patch.  And so they can review it effectively, etc.
> I'm going to update the description with the following passage:
> 
>     Print the currently enabled stack and heap initialization modes.
> 
>     Stack initialization is enabled by a config flag, while heap
>     initialization is configured at boot time with defaults being set
>     in the config. It's more convenient for the user to have all information
>     about these hardening measures in one place.
> 
> Does this make sense?
> > Always!
> >
> > > In the init_on_free mode initializing pages at boot time may take some
> > > time, so print a notice about that as well.
> >
> > How much time?
> I've seen pauses up to 1 second, not actually sure they're worth a
> separate line in the log.
> Kees, how long were the delays in your case?

I didn't measure it, but I think it was something like 0.5 second per GB.
I noticed because normally boot flashes by. With init_on_free it pauses
for no apparent reason, which is why I suggested the note. (I mean *I*
knew why it was pausing, but it might surprise someone who sets
init_on_free=1 without really thinking about what's about to happen at
boot.)

-- 
Kees Cook


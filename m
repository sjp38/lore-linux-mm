Return-Path: <SRS0=EPqI=U2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 91148C48BD7
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 09:27:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 559922083B
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 09:27:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 559922083B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E36E28E0003; Thu, 27 Jun 2019 05:27:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DE92A8E0002; Thu, 27 Jun 2019 05:27:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CD6918E0003; Thu, 27 Jun 2019 05:27:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7DAC78E0002
	for <linux-mm@kvack.org>; Thu, 27 Jun 2019 05:27:25 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id i9so5593772edr.13
        for <linux-mm@kvack.org>; Thu, 27 Jun 2019 02:27:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=ezHGMx/lWkQ5D5sL3epURlcSKb8vSupR8CR8jsMUXoo=;
        b=MEFeYGa/bMCLDhpquPwwqlthFHxf1AkntcsQY79xJkatilluzrkeah1SUllQADzIwS
         dadoKS20FQgfFYhOIOAfrpdRovQFWB40eKAjf1Ym2vDrGnKMxvOeb3BBBhxO+Dv9N2FL
         MKw5KrTyVfT7Sjso4iy+p31hgMWCnMst/nEsHdtCSm5YkhhlTP3kqa0uSQRoypXqhY7X
         HfvdyynEf7yPGEHpHoBbtF0BloDQZT3O3kY1seHGVfu+p3VwtQ8LAqKjK5yjYINtBcwN
         BmGN5qID5pjuz/YL+61Xa3Q/DWyi03ivtZ++c+ZwVM6mWppND6akwrfGLwU4XJKdsO+8
         4BjQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of dave.martin@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=Dave.Martin@arm.com
X-Gm-Message-State: APjAAAVqetpD6lsL55FrstJLA7KAXAZcLbFxAuOP4HiM208ppMP/+RGT
	AAWc6SD2hMFJCSoJ/iF8pc7NtvHVe8b2o49aShWlzOJXD6TDaYyrPpi+9mzadbRhrM80pA1KZFm
	A3W0JMmI7yOgnAo/VHtzbDZCAKUhpLR/fEzfdbEJYGJgYFK8SJs5CD5aVeES0KEhVDA==
X-Received: by 2002:a50:b187:: with SMTP id m7mr2802722edd.81.1561627644913;
        Thu, 27 Jun 2019 02:27:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxlmSin1CB3WYV6wdA/qAMG4lUYky9QxKhvVwr/JkyIRq0Xe/tY/u9lRuJSDmVfSlyzTyIW
X-Received: by 2002:a50:b187:: with SMTP id m7mr2802665edd.81.1561627644170;
        Thu, 27 Jun 2019 02:27:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561627644; cv=none;
        d=google.com; s=arc-20160816;
        b=TuaLowLNb7CW2/zjckZrRTvRNnwOSn47Z1BedjpHmKtTrNy84w+3RtyTO8YfgZalhh
         UaYuhxWFttql3ITpaYLk6paUDBpALAsJUfAcoT9UeHvBv5ncJwfAn8GaO1d1HaJrjIC/
         JkhOfUg+3qO5S/DFnFe5wyWURxk6QrrlsVwHxrRbRGFuOIy9nLI+OE4u2tCZ/I8LCRRD
         XDHOFlGOKrwgSuNWUQcfvf0c+bP/DwXu+TUZmq1hEL2OPqzBt9cNYIw+E42AW0TFExTi
         Wj2DVMRLPo7+6rIqetlKpIZd4KJajm4hnc/aysTqwaXxe3AhfrsKKK0AwK0eylW3TmiC
         2qUQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=ezHGMx/lWkQ5D5sL3epURlcSKb8vSupR8CR8jsMUXoo=;
        b=bvaAtlOSetrcFh3CjU0XkRmgbYSSBazRTMAKEJWPHSGnmznBN4GcxbfVE6wjyrgsPE
         XnARw27wBqpiCOOcEGLgCo0R4/SsjxRptKg/rBfh55DFAdy58PvFa6NgScC4Hcj+KYzZ
         Sjbi1n1S/0+jD39cOiRu+wmmodVuOhKZ/ymiao2HFt5ulUetvO3u6SInk+HMMLswusvC
         kMvpZqz9nO6oLXe2Phzu5Wh1g7M03z7Jf37mg6eY12My/T926NOZC23di+mmuBN9mhEy
         rouyYw/vTRUwxH93XDE3xfsQ8cEg1+lTQkZLikP3nDBUGTrlxaA8KliHrHMdLNpZtj+V
         e+Nw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of dave.martin@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=Dave.Martin@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id q10si1070204ejn.365.2019.06.27.02.27.23
        for <linux-mm@kvack.org>;
        Thu, 27 Jun 2019 02:27:24 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of dave.martin@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of dave.martin@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=Dave.Martin@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 0EA992B;
	Thu, 27 Jun 2019 02:27:23 -0700 (PDT)
Received: from e103592.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.121.207.14])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 5BA343F718;
	Thu, 27 Jun 2019 02:27:19 -0700 (PDT)
Date: Thu, 27 Jun 2019 10:27:17 +0100
From: Dave Martin <Dave.Martin@arm.com>
To: Andy Lutomirski <luto@kernel.org>
Cc: Yu-cheng Yu <yu-cheng.yu@intel.com>, X86 ML <x86@kernel.org>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, LKML <linux-kernel@vger.kernel.org>,
	"open list:DOCUMENTATION" <linux-doc@vger.kernel.org>,
	Linux-MM <linux-mm@kvack.org>,
	linux-arch <linux-arch@vger.kernel.org>,
	Linux API <linux-api@vger.kernel.org>,
	Arnd Bergmann <arnd@arndb.de>, Balbir Singh <bsingharora@gmail.com>,
	Cyrill Gorcunov <gorcunov@gmail.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Eugene Syromiatnikov <esyr@redhat.com>,
	Florian Weimer <fweimer@redhat.com>,
	"H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>,
	Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>,
	Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>,
	Randy Dunlap <rdunlap@infradead.org>,
	"Ravi V. Shankar" <ravi.v.shankar@intel.com>,
	Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>,
	Szabolcs Nagy <szabolcs.nagy@arm.com>,
	libc-alpha <libc-alpha@sourceware.org>
Subject: Re: [PATCH] binfmt_elf: Extract .note.gnu.property from an ELF file
Message-ID: <20190627092715.GB2790@e103592.cambridge.arm.com>
References: <20190501211217.5039-1-yu-cheng.yu@intel.com>
 <20190502111003.GO3567@e103592.cambridge.arm.com>
 <CALCETrVZCzh+KFCF6ijuf4QEPn=R2gJ8FHLpyFd=n+pNOMMMjA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrVZCzh+KFCF6ijuf4QEPn=R2gJ8FHLpyFd=n+pNOMMMjA@mail.gmail.com>
User-Agent: Mutt/1.5.23 (2014-03-12)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 26, 2019 at 10:14:07AM -0700, Andy Lutomirski wrote:
> On Thu, May 2, 2019 at 4:10 AM Dave Martin <Dave.Martin@arm.com> wrote:

[...]

> > A couple of questions before I look in more detail:
> >
> > 1) Can we rely on PT_GNU_PROPERTY being present in the phdrs to describe
> > the NT_GNU_PROPERTY_TYPE_0 note?  If so, we can avoid trying to parse
> > irrelevant PT_NOTE segments.
> >
> >
> > 2) Are there standard types for things like the program property header?
> > If not, can we add something in elf.h?  We should try to coordinate with
> > libc on that.  Something like
> >
> 
> Where did PT_GNU_PROPERTY come from?  Are there actual docs for it?
> Can someone here tell us what the actual semantics of this new ELF
> thingy are?  From some searching, it seems like it's kind of an ELF
> note but kind of not.  An actual description would be fantastic.

https://github.com/hjl-tools/linux-abi/wiki/linux-abi-draft.pdf

I don't know _when_ it was added, and the description is minimal, but
it's there.

(I'd say it's fairly obvious how it should be used, but it could do with
some clarification...)

> Also, I don't think there's any actual requirement that the upstream
> kernel recognize existing CET-enabled RHEL 8 binaries as being
> CET-enabled.  I tend to think that RHEL 8 jumped the gun here.  While
> the upstream kernel should make some reasonble effort to make sure
> that RHEL 8 binaries will continue to run, I don't see why we need to
> go out of our way to keep the full set of mitigations available for
> binaries that were developed against a non-upstream kernel.

If that's an accpetable approach, it should certainly make our life
easier.

> In fact, if we handle the legacy bitmap differently from RHEL 8, we
> may *have* to make sure that we don't recognize existing RHEL 8
> binaries as CET-enabled.

Can't comment on that.  If the existing RHEL 8 binaries strictly don't
have the PT_GNU_PROPERTY phdr, then this might serve a dual purpose ...
otherwise, x86 might need some additional annotation for new binaries.

I'll leave it for others to comment.

Cheers
---Dave


Return-Path: <SRS0=aN9C=WJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 48DEBC32753
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 15:29:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F1B0C2084D
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 15:29:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="bImk/Y4v"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F1B0C2084D
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 80C096B0006; Tue, 13 Aug 2019 11:29:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7E2496B0007; Tue, 13 Aug 2019 11:29:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 720F26B0008; Tue, 13 Aug 2019 11:29:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0041.hostedemail.com [216.40.44.41])
	by kanga.kvack.org (Postfix) with ESMTP id 5299C6B0006
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 11:29:38 -0400 (EDT)
Received: from smtpin03.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 0F1EB181AC9B6
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 15:29:38 +0000 (UTC)
X-FDA: 75817789236.03.bird06_19d1164247427
X-HE-Tag: bird06_19d1164247427
X-Filterd-Recvd-Size: 7239
Received: from mail-ot1-f68.google.com (mail-ot1-f68.google.com [209.85.210.68])
	by imf02.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 15:29:37 +0000 (UTC)
Received: by mail-ot1-f68.google.com with SMTP id g17so23054378otl.2
        for <linux-mm@kvack.org>; Tue, 13 Aug 2019 08:29:36 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=jMeI5ltMPEKZ0Tj88O24MXE9cWJp6pw2JTg4dO3y4Mo=;
        b=bImk/Y4vshDj5gFBaBVzsjv6Rz+kwzqnWzrOBiLYKXqof3GfeusuSBS3ZiJ0pa2Biz
         +tCSIZX2wDwVr22g3BeKZT3HzY/3F3KR5WgLqESzTmOD6PixUCsy4sgNyuiEqlGA2Bjp
         O3h7Bxpj0KGCCfJLCDX5YuylzaDhD6YWh0+jnG/g8GPay7nwiIg92/zGE80yk/76C2Ir
         tInAOj2kgN2/l0orZzstbjsX+QeiJpnBb75cjQr+tZH8sYPtvAJiOVQTMuMyxL1xu9O/
         oCa/4Px4H0ZvIlllpY5mSai4UcuTIufdPCdutaJGOguKuqlkfxkxQaDhfVzv45rlbMpZ
         AHIw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=jMeI5ltMPEKZ0Tj88O24MXE9cWJp6pw2JTg4dO3y4Mo=;
        b=I7Fyg8pp/Z8mYT2ivo8itELbrco2DC2VdFCsapuIYzIsY/4W4RHD9h8+JBVQXg61q4
         ptbwHIOQaoqoZYDtvs7TTOJOsWJzZp7fGSNm0BR0oGGtN3o6Z//JPNfTtesyGG9trlUA
         m7gzNAUh9PPBEFi8yreXTJ71sXckDSkpnhTOKw2ggtguB9mRyxpta7jNp3bLEvqI6XFs
         c6PWDtqZ30SUpFldt/e4F0G2XXwEBwMKVPh95s03PEhDoB5CqwQequbChXY6TNp6TjSX
         YpbaXkoCJCUoBWBgWJNu7yzQhjKE5h9zKFnakw7U09CB1QD5AzYuieXNyh6EaOcgPfQV
         mXFA==
X-Gm-Message-State: APjAAAVrGfstb8c7CatOeCtvSRem/v9kKbiqedji1xoE/1x3pHH45yoQ
	WmDqQW3YGikd4E9WKBMcFF3bqBNcUhV+/7LNYDxFtg==
X-Google-Smtp-Source: APXvYqxQEaHf3X4y40GcHw/mVHg70puR4hMjqYUOR1PPtguEpeRZ2mELIIydxgtCS2soxOtuvIFl0/ZHBeOF0COouWI=
X-Received: by 2002:a9d:5a91:: with SMTP id w17mr35070043oth.32.1565710175793;
 Tue, 13 Aug 2019 08:29:35 -0700 (PDT)
MIME-Version: 1.0
References: <20190807171559.182301-1-joel@joelfernandes.org>
 <CAG48ez0ysprvRiENhBkLeV9YPTN_MB18rbu2HDa2jsWo5FYR8g@mail.gmail.com> <20190813100856.GF17933@dhcp22.suse.cz>
In-Reply-To: <20190813100856.GF17933@dhcp22.suse.cz>
From: Jann Horn <jannh@google.com>
Date: Tue, 13 Aug 2019 17:29:09 +0200
Message-ID: <CAG48ez2cuqe_VYhhaqw8Hcyswv47cmz2XmkqNdvkXEhokMVaXg@mail.gmail.com>
Subject: Re: [PATCH v5 1/6] mm/page_idle: Add per-pid idle page tracking using
 virtual index
To: Michal Hocko <mhocko@kernel.org>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, 
	"Joel Fernandes (Google)" <joel@joelfernandes.org>
Cc: kernel list <linux-kernel@vger.kernel.org>, Alexey Dobriyan <adobriyan@gmail.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Borislav Petkov <bp@alien8.de>, 
	Brendan Gregg <bgregg@netflix.com>, Catalin Marinas <catalin.marinas@arm.com>, 
	Christian Hansen <chansen3@cisco.com>, Daniel Colascione <dancol@google.com>, fmayer@google.com, 
	"H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, Joel Fernandes <joelaf@google.com>, 
	Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, 
	kernel-team <kernel-team@android.com>, Linux API <linux-api@vger.kernel.org>, 
	linux-doc@vger.kernel.org, linux-fsdevel <linux-fsdevel@vger.kernel.org>, 
	Linux-MM <linux-mm@kvack.org>, Mike Rapoport <rppt@linux.ibm.com>, 
	Minchan Kim <minchan@kernel.org>, namhyung@google.com, 
	"Paul E. McKenney" <paulmck@linux.ibm.com>, Robin Murphy <robin.murphy@arm.com>, 
	Roman Gushchin <guro@fb.com>, Stephen Rothwell <sfr@canb.auug.org.au>, 
	Suren Baghdasaryan <surenb@google.com>, Thomas Gleixner <tglx@linutronix.de>, Todd Kjos <tkjos@google.com>, 
	Vladimir Davydov <vdavydov.dev@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, Will Deacon <will@kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 13, 2019 at 12:09 PM Michal Hocko <mhocko@kernel.org> wrote:
> On Mon 12-08-19 20:14:38, Jann Horn wrote:
> > On Wed, Aug 7, 2019 at 7:16 PM Joel Fernandes (Google)
> > <joel@joelfernandes.org> wrote:
> > > The page_idle tracking feature currently requires looking up the pagemap
> > > for a process followed by interacting with /sys/kernel/mm/page_idle.
> > > Looking up PFN from pagemap in Android devices is not supported by
> > > unprivileged process and requires SYS_ADMIN and gives 0 for the PFN.
> > >
> > > This patch adds support to directly interact with page_idle tracking at
> > > the PID level by introducing a /proc/<pid>/page_idle file.  It follows
> > > the exact same semantics as the global /sys/kernel/mm/page_idle, but now
> > > looking up PFN through pagemap is not needed since the interface uses
> > > virtual frame numbers, and at the same time also does not require
> > > SYS_ADMIN.
> > >
> > > In Android, we are using this for the heap profiler (heapprofd) which
> > > profiles and pin points code paths which allocates and leaves memory
> > > idle for long periods of time. This method solves the security issue
> > > with userspace learning the PFN, and while at it is also shown to yield
> > > better results than the pagemap lookup, the theory being that the window
> > > where the address space can change is reduced by eliminating the
> > > intermediate pagemap look up stage. In virtual address indexing, the
> > > process's mmap_sem is held for the duration of the access.
> >
> > What happens when you use this interface on shared pages, like memory
> > inherited from the zygote, library file mappings and so on? If two
> > profilers ran concurrently for two different processes that both map
> > the same libraries, would they end up messing up each other's data?
>
> Yup PageIdle state is shared. That is the page_idle semantic even now
> IIRC.
>
> > Can this be used to observe which library pages other processes are
> > accessing, even if you don't have access to those processes, as long
> > as you can map the same libraries? I realize that there are already a
> > bunch of ways to do that with side channels and such; but if you're
> > adding an interface that allows this by design, it seems to me like
> > something that should be gated behind some sort of privilege check.
>
> Hmm, you need to be priviledged to get the pfn now and without that you
> cannot get to any page so the new interface is weakening the rules.
> Maybe we should limit setting the idle state to processes with the write
> status. Or do you think that even observing idle status is useful for
> practical side channel attacks? If yes, is that a problem of the
> profiler which does potentially dangerous things?

I suppose read-only access isn't a real problem as long as the
profiler isn't writing the idle state in a very tight loop... but I
don't see a usecase where you'd actually want that? As far as I can
tell, if you can't write the idle state, being able to read it is
pretty much useless.

If the profiler only wants to profile process-private memory, then
that should be implementable in a safe way in principle, I think, but
since Joel said that they want to profile CoW memory as well, I think
that's inherently somewhat dangerous.


Return-Path: <SRS0=qzwp=VQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 99C38C76188
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 12:24:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5A6092184E
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 12:24:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="ZcNjefoh"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5A6092184E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E93656B0006; Fri, 19 Jul 2019 08:24:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E1DD16B0007; Fri, 19 Jul 2019 08:24:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CE54D8E0001; Fri, 19 Jul 2019 08:24:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 926D96B0006
	for <linux-mm@kvack.org>; Fri, 19 Jul 2019 08:24:17 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id z1so18609516pfb.7
        for <linux-mm@kvack.org>; Fri, 19 Jul 2019 05:24:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=dqn6UcVWjH9sdSwsVPylSPg5VYTS6ulQoDiGG1SQL9Y=;
        b=HQ6w8LghE9mKyf+QIXy0U4hE2iqRVtmdaCsBL8Z7CvJ89Gm2VSEUWDfo825Qd3oay3
         yicR3rJeJ0U/32A1og13ZWg3HDBw8wQgP+ZrYMmVObGTqw+1avSXub+Hf6G+uJCGGfKo
         BrcaRb8AO+qINniaKNW9wgavL5mXNawNcvTpfJ4XW/3OysiWuhtLiw/a3vQHUotJflEV
         2kKOugIj2f4P/dYnOq8YfIwphYHD4lbCNb5cww8KD3jzA/nOqYHS0zcVQOVizHGIVGcN
         RCwAIjv3evTCZ4FFsTS0V2qH4JXZNrHDtCl0dH+Dtsh37rfPJLPPsRdARvZvjlQfDZCC
         zi0w==
X-Gm-Message-State: APjAAAX+EcQIWetko9Y0yX7iLXxSuAlyuGOULMuPDpoB5kYPTSbOVDFq
	cmCoeJM3/u2fHCzh5QimeoWb/tLyjDSqxcvcM8RldbRtyUURMDLWfXkIkpmvzV1ADpIOV1sgpOC
	xeMszoxHSy8QhYlrPT4rQVMyz6LzN4Fl39XoElclERUeWs4bRWhWN6Cb8a3HZJ2iRbw==
X-Received: by 2002:a17:90a:ca11:: with SMTP id x17mr58094158pjt.107.1563539057207;
        Fri, 19 Jul 2019 05:24:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxZJpUNnb/QjsgerjdP1U3k5adTGHuMyyn+gA/kE1l0uk+psQiLv4k27exEANGTmVNM+OMn
X-Received: by 2002:a17:90a:ca11:: with SMTP id x17mr58094101pjt.107.1563539056475;
        Fri, 19 Jul 2019 05:24:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563539056; cv=none;
        d=google.com; s=arc-20160816;
        b=Nu9IhNyInXbhpTBoCHwV6Ii0vTQlJ+8vvBfOQLXnPsoR+YouHhdcS/innbx6ktnf+B
         Hy8fVD3l8jlB/eUoRfSYEINnyC7gca7sJlt/IXbaRRT5/84nB2WK/eGw1UWwN5EKSeZ/
         WbqTFnsJ0DR0YqUkxaLWA9repSA08EIoSaBZYde5pLGEnPQ+iOPtnWR2S7vMmsjFYqu0
         cQmEBQBWMol2WsHh7unJJk6UimXvOktxC46GXZv+nsddDfb2/6b3IxCsErPKPBx2bBYI
         bZtjGeDprm04/yNwKTWw2N5ylA3+Uqib1tYrOl5npizU2Hh4C53i216G8Z0tu+M5r2bo
         /Rxg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=dqn6UcVWjH9sdSwsVPylSPg5VYTS6ulQoDiGG1SQL9Y=;
        b=F48IQoJ5rE9PoSCzSGybV/IsYOgjPNHpQweHwQT2OnVPzftZbU5jvFQtfnrrhgxNiN
         sDyaukVFtf/DmFdSpLrVv5rwJhmmPc/yyscTgSuNCCNyn/1otA2cENe8kmIzXGUVnLdC
         sINK/70Hza6X4RG1rbJcVZoSiDFCbkhOmgnjsDwt2A/lvV/seRl6qK6Z5r9PRf0Vz5TB
         1a4XGUwe+6+S6eOkqWW6f0xHI8jseRnJcWnHk7Zwz0UYOpb/5EzA6g8I2Nhlb/G3sSOK
         Pgha3iiBDq/U7dAWkGle5nSniayCAQw7ZWKqCd6MQAF9Uzdexi20eRdibwyWTaax75OW
         WcLw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=ZcNjefoh;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id cb13si27927109plb.325.2019.07.19.05.24.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Jul 2019 05:24:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=ZcNjefoh;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-wr1-f49.google.com (mail-wr1-f49.google.com [209.85.221.49])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id DBA542184E
	for <linux-mm@kvack.org>; Fri, 19 Jul 2019 12:24:15 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1563539056;
	bh=Ck4eZ/5Sqk7t+dWiweDZ19MBs3yztrS1A6zmoiFGVAw=;
	h=References:In-Reply-To:From:Date:Subject:To:Cc:From;
	b=ZcNjefoh2NgQpIgYbn+H2tVOGJH8ErxcAhc6+nhkF2NKowZQmfV/bo9bFIeERf6V+
	 e5lEbDQVV+FjMtX+0oLpIZOZOF9kLkX08V64y5bEm2Tk69vUbmMkunpHRdqm7EDgXk
	 orAA3mbAq+W7VQCoANy++bomLiKbdAY+oZSYbb/s=
Received: by mail-wr1-f49.google.com with SMTP id n4so32135680wrs.3
        for <linux-mm@kvack.org>; Fri, 19 Jul 2019 05:24:15 -0700 (PDT)
X-Received: by 2002:adf:dd0f:: with SMTP id a15mr15129921wrm.265.1563539054479;
 Fri, 19 Jul 2019 05:24:14 -0700 (PDT)
MIME-Version: 1.0
References: <20190717071439.14261-1-joro@8bytes.org> <20190717071439.14261-4-joro@8bytes.org>
 <CALCETrXfCbajLhUixKNaMfFw91gzoQzt__faYLwyBqA3eAbQVA@mail.gmail.com>
 <20190718091745.GG13091@suse.de> <CALCETrXJYuHN872F74kVTuw4dYOc5saKqoUFbgJ5X0EuGEhXcA@mail.gmail.com>
 <20190719122111.GD19068@suse.de>
In-Reply-To: <20190719122111.GD19068@suse.de>
From: Andy Lutomirski <luto@kernel.org>
Date: Fri, 19 Jul 2019 05:24:03 -0700
X-Gmail-Original-Message-ID: <CALCETrUjATNr97ZWX41Tt3QyiMM+GSqG92Nn=qZTTG6XrvL8GQ@mail.gmail.com>
Message-ID: <CALCETrUjATNr97ZWX41Tt3QyiMM+GSqG92Nn=qZTTG6XrvL8GQ@mail.gmail.com>
Subject: Re: [PATCH 3/3] mm/vmalloc: Sync unmappings in vunmap_page_range()
To: Joerg Roedel <jroedel@suse.de>
Cc: Andy Lutomirski <luto@kernel.org>, Joerg Roedel <joro@8bytes.org>, 
	Dave Hansen <dave.hansen@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, 
	Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, 
	Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, 
	Linux-MM <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jul 19, 2019 at 5:21 AM Joerg Roedel <jroedel@suse.de> wrote:
>
> On Thu, Jul 18, 2019 at 12:04:49PM -0700, Andy Lutomirski wrote:
> > I find it problematic that there is no meaningful documentation as to
> > what vmalloc_sync_all() is supposed to do.
>
> Yeah, I found that too, there is no real design around
> vmalloc_sync_all(). It looks like it was just added to fit the purpose
> on x86-32. That also makes it hard to find all necessary call-sites.
>
> > Which is obviously entirely inapplicable.  If I'm understanding
> > correctly, the underlying issue here is that the vmalloc fault
> > mechanism can propagate PGD entry *addition*, but nothing (not even
> > flush_tlb_kernel_range()) propagates PGD entry *removal*.
>
> Close, the underlying issue is not about PGD, but PMD entry
> addition/removal on x86-32 pae systems.
>
> > I find it suspicious that only x86 has this.  How do other
> > architectures handle this?
>
> The problem on x86-PAE arises from the !SHARED_KERNEL_PMD case, which was
> introduced by the  Xen-PV patches and then re-used for the PTI-x32
> enablement to be able to map the LDT into user-space at a fixed address.
>
> Other architectures probably don't have the !SHARED_KERNEL_PMD case (or
> do unsharing of kernel page-tables on any level where a huge-page could
> be mapped).
>
> > At the very least, I think this series needs a comment in
> > vmalloc_sync_all() explaining exactly what the function promises to
> > do.
>
> Okay, as it stands, it promises to sync mappings for the vmalloc area
> between all PGDs in the system. I will add that as a comment.
>
> > But maybe a better fix is to add code to flush_tlb_kernel_range()
> > to sync the vmalloc area if the flushed range overlaps the vmalloc
> > area.
>
> That would also cause needless overhead on x86-64 because the vmalloc
> area doesn't need syncing there. I can make it x86-32 only, but that is
> not a clean solution imo.

Could you move the vmalloc_sync_all() call to the lazy purge path,
though?  If nothing else, it will cause it to be called fewer times
under any given workload, and it looks like it could be rather slow on
x86_32.

>
> > Or, even better, improve x86_32 the way we did x86_64: adjust
> > the memory mapping code such that top-level paging entries are never
> > deleted in the first place.
>
> There is not enough address space on x86-32 to partition it like on
> x86-64. In the default PAE configuration there are _four_ PGD entries,
> usually one for the kernel, and then 512 PMD entries. Partitioning
> happens on the PMD level, for example there is one entry (2MB of address
> space) reserved for the user-space LDT mapping.

Ugh, fair enough.


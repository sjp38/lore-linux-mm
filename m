Return-Path: <SRS0=8Dof=TA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 391BAC43219
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 16:44:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EE08F21734
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 16:44:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="0Cwgl455"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EE08F21734
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 823EC6B0003; Tue, 30 Apr 2019 12:44:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7D4C06B0005; Tue, 30 Apr 2019 12:44:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 69CE66B0006; Tue, 30 Apr 2019 12:44:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 323036B0003
	for <linux-mm@kvack.org>; Tue, 30 Apr 2019 12:44:24 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id e12so9375986pgh.2
        for <linux-mm@kvack.org>; Tue, 30 Apr 2019 09:44:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=J1qJxdnx9wSU4R8P+0fGV/kWZnabM/4xN4pzgyRbyRs=;
        b=JjRV4hN5k/7uYREWujDQ6h05jAPaw8oEVN48gu4uRoB21ywoL2PNXmkAXAiQHmV8Zo
         0osdbO7wQuQXrCpci7yJuaEqVnIY564DZEI0aZNAJ3eqLfY28z8faHpIBkpRPpSoap0X
         csHJ5oPKblrB3gMMHz4KB8U73Yxz/raot1Pprm3ExnLaXU0t0rMCUa1Il6PQKKeovn4O
         mQ9rxPaLY+CuDeI4YTFLOnWCUSQ4bdDvgKBk0J1Su2FtxSA0KO5NQD0mdqSXljsx3/fv
         M2lDNT8vv8ZtgdcBNayFIMfdfXGj56H6enIdjR5ZoB3uM9jDF6ARaHhVakdM4yEpBBgU
         bfdg==
X-Gm-Message-State: APjAAAWAx8OZsm1Nb1YYC68bycQsEsuAHHu5c628LvUaIgVfIfkpoQsc
	bfGGgRBi0oc44UtlElToOu1xWGs5BSsAubzojNtvfA1+0+nYWarCZ5z+GquG2VSpfdnOSZJiCg3
	BN1gc1cAKxPR8PpU2L8vqcrfEQAyoy9ArUpq/eA939FjbKnh5tFAOL7kEPdrZ/oFNGg==
X-Received: by 2002:a17:902:7609:: with SMTP id k9mr6639304pll.186.1556642663864;
        Tue, 30 Apr 2019 09:44:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxF3pUbC5NSJJBEJXdGRF0loZ6MKWUEK/7VEJGSyC07gQrPtCM7IuCDb6E5P6hV6nDNzZFs
X-Received: by 2002:a17:902:7609:: with SMTP id k9mr6639188pll.186.1556642662783;
        Tue, 30 Apr 2019 09:44:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556642662; cv=none;
        d=google.com; s=arc-20160816;
        b=uEOGk2WCM8qHBnhIeN+7x6yUDhOos9yE23tki2p+aFWQ4H5S2/mBv3gl+O161z9fov
         1dXKwGDLpE656ioDMLMerZgAeQMljMBwVcyO2a8vhhLw+SalrTzrJ2TC/z7EHK+eb4ZP
         GbsDlkBAvmJ9L9Z/P+jPArdMO75AZXLAapxaCRFfpi4/ibYmiUv9oYFXFNTB6Iw5sNau
         eEN4uesILXidTzTe3arYSGzoRy/+clDdeCv6zY03U5tMVMbZdddgRuueIrio/dQldSod
         reFnjpedotXJcTNAIm+MzfymnksoEywpdfmaDV7fhf4d1UfeIf/NGvyQiQq3dsNPuIz9
         fMig==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=J1qJxdnx9wSU4R8P+0fGV/kWZnabM/4xN4pzgyRbyRs=;
        b=V6T0RJgqbTDwSNF18GCJdmmYPhvTBvL0XAxkbcmvrp8f1eJRwO0oS4kekM6OmggfzX
         tO3aPTWAF30c7fgWmPJuCV+Krsnw0Uu7zJNFojMYUzH2PtZJegxXrtmPiASFYjYJD80W
         Rxe+UH3rhxd+uJpkOFqSD9Mz8yc9ov0ah13x0DGDJGP9sS47SEMu7feLoptaGMb5wYo6
         oQcYwSg0Tmh5htwvlez+YeITesAA7U3LFTxnr2dp6KxPH4G3PzFlCpx4h9lBGGdlI5Fd
         EpdCTzMYhQ6BBfbyQTeAE7tH0dMInJRExR0dRAePdlZmgL4m2jXUG3/q+hoYvkk2wDBi
         rcwQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=0Cwgl455;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id l185si25125221pgl.48.2019.04.30.09.44.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Apr 2019 09:44:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=0Cwgl455;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-wr1-f52.google.com (mail-wr1-f52.google.com [209.85.221.52])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id D2DB72177B
	for <linux-mm@kvack.org>; Tue, 30 Apr 2019 16:44:21 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1556642662;
	bh=X+93M0oEsG72OeT0c4AH+IZFAW8t4zob5MBGfr+nR9E=;
	h=References:In-Reply-To:From:Date:Subject:To:Cc:From;
	b=0Cwgl455POKYMyoluPcjKgBdy7MMFfOBK6PhZ3vnyEg4hzP6tOhml4qkU7KTNKmik
	 4VEYMrW936vYFJxKyXvtLznG+d7qY7wXLGmlS8zYEz+zTbTOHnlvichZVCogwT8K2S
	 a0CWqzM+0emJWwLc4qdt1sFhXsGIjcES73x5topM=
Received: by mail-wr1-f52.google.com with SMTP id k16so21829679wrn.5
        for <linux-mm@kvack.org>; Tue, 30 Apr 2019 09:44:21 -0700 (PDT)
X-Received: by 2002:a5d:424e:: with SMTP id s14mr22195947wrr.77.1556642660479;
 Tue, 30 Apr 2019 09:44:20 -0700 (PDT)
MIME-Version: 1.0
References: <1556228754-12996-1-git-send-email-rppt@linux.ibm.com>
 <1556228754-12996-6-git-send-email-rppt@linux.ibm.com> <20190426074223.GY4038@hirez.programming.kicks-ass.net>
 <20190428054711.GD14896@rapoport-lnx>
In-Reply-To: <20190428054711.GD14896@rapoport-lnx>
From: Andy Lutomirski <luto@kernel.org>
Date: Tue, 30 Apr 2019 09:44:09 -0700
X-Gmail-Original-Message-ID: <CALCETrWrtRo1PqdVmJQQ95J8ORy9WBkUraJCqL6JNmmAkw=H0w@mail.gmail.com>
Message-ID: <CALCETrWrtRo1PqdVmJQQ95J8ORy9WBkUraJCqL6JNmmAkw=H0w@mail.gmail.com>
Subject: Re: [RFC PATCH 5/7] x86/mm/fault: hook up SCI verification
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, LKML <linux-kernel@vger.kernel.org>, 
	Alexandre Chartre <alexandre.chartre@oracle.com>, Andy Lutomirski <luto@kernel.org>, 
	Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, 
	"H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, 
	James Bottomley <James.Bottomley@hansenpartnership.com>, Jonathan Adams <jwadams@google.com>, 
	Kees Cook <keescook@chromium.org>, Paul Turner <pjt@google.com>, 
	Thomas Gleixner <tglx@linutronix.de>, Linux-MM <linux-mm@kvack.org>, 
	LSM List <linux-security-module@vger.kernel.org>, X86 ML <x86@kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Apr 27, 2019 at 10:47 PM Mike Rapoport <rppt@linux.ibm.com> wrote:
>
> On Fri, Apr 26, 2019 at 09:42:23AM +0200, Peter Zijlstra wrote:
> > On Fri, Apr 26, 2019 at 12:45:52AM +0300, Mike Rapoport wrote:
> > > If a system call runs in isolated context, it's accesses to kernel code and
> > > data will be verified by SCI susbsytem.
> > >
> > > Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
> > > ---
> > >  arch/x86/mm/fault.c | 28 ++++++++++++++++++++++++++++
> > >  1 file changed, 28 insertions(+)
> >
> > There's a distinct lack of touching do_double_fault(). It appears to me
> > that you'll instantly trigger #DF when you #PF, because the #PF handler
> > itself will not be able to run.
>
> The #PF handler is able to run. On interrupt/error entry the cr3 is
> switched to the full kernel page tables, pretty much like PTI does for
> user <-> kernel transitions. It's in the patch 3.
>
>

PeterZ meant page_fault, not do_page_fault.  In your patch, page_fault
and some of error_entry run before that magic switchover happens.  If
they're not in the page tables, you double-fault.

And don't even try to do SCI magic in the double-fault handler.  As I
understand it, the SDM and APM aren't kidding when they say that #DF
is an abort, not a fault.  There is a single case in the kernel where
we recover from #DF, and it was vetted by microcode people.


Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5D3EA6B02F3
	for <linux-mm@kvack.org>; Mon,  7 Aug 2017 15:01:15 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id b184so973647oih.9
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 12:01:15 -0700 (PDT)
Received: from mail-io0-x243.google.com (mail-io0-x243.google.com. [2607:f8b0:4001:c06::243])
        by mx.google.com with ESMTPS id c1si5375501oih.88.2017.08.07.12.01.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Aug 2017 12:01:14 -0700 (PDT)
Received: by mail-io0-x243.google.com with SMTP id j32so944610iod.3
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 12:01:14 -0700 (PDT)
Message-ID: <1502132471.1803.13.camel@gmail.com>
Subject: Re: binfmt_elf: use ELF_ET_DYN_BASE only for PIE breaks asan
From: Daniel Micay <danielmicay@gmail.com>
Date: Mon, 07 Aug 2017 15:01:11 -0400
In-Reply-To: <CAGXu5jJOOvv=zgSWnKJOae0edKG8MUV1pto1ipijPiRsOdKr+Q@mail.gmail.com>
References: 
	<CACT4Y+bLGEC=14CUJpkMhw0toSxvbyqKj49kqqW+gCLLBDFu4A@mail.gmail.com>
	 <CAGXu5jJhFt8JNFRnB-oiGjNy=Auo4bGx=i=DDtCa__20acANBQ@mail.gmail.com>
	 <CAN=P9pj_jbTgGoiECmu-b=s+NOL6uTkPbXDueXLhs8C6PVbLHg@mail.gmail.com>
	 <CAGXu5jLRG6Xee-dJGPwmbfcVFLuTP9+5mexJyvZamQQdSaHNtA@mail.gmail.com>
	 <1502131739.1803.12.camel@gmail.com>
	 <CAGXu5jKj0M55wK=0WE_uKJpiJ031J5jPVAZR-VA7_O2qJUi=BQ@mail.gmail.com>
	 <CAN=P9pj0TSbwTogLAJrm=yszq+86X0EmXNK-0Oq9f7wQCkQRjA@mail.gmail.com>
	 <CAGXu5jJOOvv=zgSWnKJOae0edKG8MUV1pto1ipijPiRsOdKr+Q@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@google.com>, Kostya Serebryany <kcc@google.com>
Cc: Dmitry Vyukov <dvyukov@google.com>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Reid Kleckner <rnk@google.com>, Peter Collingbourne <pcc@google.com>, Evgeniy Stepanov <eugenis@google.com>

On Mon, 2017-08-07 at 11:59 -0700, Kees Cook wrote:
> On Mon, Aug 7, 2017 at 11:56 AM, Kostya Serebryany <kcc@google.com>
> wrote:
> > Is it possible to implement some userspace<=>kernel interface that
> > will
> > allow applications (sanitizers)
> > to request *fixed* address ranges from the kernel at startup (so
> > that the
> > kernel couldn't refuse)?
> 
> Wouldn't building non-PIE accomplish this?
> 
> -Kees
> 

Well that lets you map the executable in the desired location, and
sanitizers would be free to add a huge reserved mapping as part of the
executable, but if they want the mapping placed away from the exe there
is not really any way to do that reliably without it being dynamic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

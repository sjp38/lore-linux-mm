Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id 420EA6B0005
	for <linux-mm@kvack.org>; Sun,  3 Jul 2016 10:36:51 -0400 (EDT)
Received: by mail-yw0-f198.google.com with SMTP id i12so63430005ywa.0
        for <linux-mm@kvack.org>; Sun, 03 Jul 2016 07:36:51 -0700 (PDT)
Received: from mail-vk0-x22c.google.com (mail-vk0-x22c.google.com. [2607:f8b0:400c:c05::22c])
        by mx.google.com with ESMTPS id 16si633464uae.134.2016.07.03.07.36.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 03 Jul 2016 07:36:50 -0700 (PDT)
Received: by mail-vk0-x22c.google.com with SMTP id k68so119179571vkb.0
        for <linux-mm@kvack.org>; Sun, 03 Jul 2016 07:36:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160701164656.GG4593@pd.tnic>
References: <20160701001209.7DA24D1C@viggo.jf.intel.com> <20160701001210.AA77B917@viggo.jf.intel.com>
 <20160701092300.GD4593@pd.tnic> <CALCETrV+uq4fcgmUK_u6_Tu6Ex3FrYM0fQjDbjwy5KZ8f8OuHg@mail.gmail.com>
 <20160701164656.GG4593@pd.tnic>
From: Andy Lutomirski <luto@amacapital.net>
Date: Sun, 3 Jul 2016 07:36:30 -0700
Message-ID: <CALCETrXXTijS0pbd2n9Rh_1AMsaerbGxC06mDmXoYm8rCDKpvg@mail.gmail.com>
Subject: Re: [PATCH 1/6] x86: fix duplicated X86_BUG(9) macro
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Michal Hocko <mhocko@suse.com>, X86 ML <x86@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, stable <stable@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dave Hansen <dave@sr71.net>, Linus Torvalds <torvalds@linux-foundation.org>, Andi Kleen <ak@linux.intel.com>

On Jul 1, 2016 9:47 AM, "Borislav Petkov" <bp@alien8.de> wrote:
>
> On Fri, Jul 01, 2016 at 09:30:37AM -0700, Andy Lutomirski wrote:
> > I put the ifdef there to prevent anyone from accidentally using it in
> > a 64-bit code path, not to save a bit.  We could put in the middle of
> > the list to make the mistake much less likely to be repeated, I
> > suppose.
>
> Well, if someone does, someone will notice pretty soon, no?

Dunno.  ESPFIX was broken under KVM for years and no one notices.

>
> I just don't see the reason to worry but maybe I'm missing it.
>
> And we can call it X86_BUG_ESPFIX_X86_32 or so too...

We could do that, too, I guess.  But the current solution is only two
extra lines of code.  We could reorder the things so that it's in the
middle instead of at the end, I suppose.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

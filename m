Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f180.google.com (mail-ob0-f180.google.com [209.85.214.180])
	by kanga.kvack.org (Postfix) with ESMTP id 5927F6B0005
	for <linux-mm@kvack.org>; Wed, 17 Feb 2016 19:47:00 -0500 (EST)
Received: by mail-ob0-f180.google.com with SMTP id wb13so42946696obb.1
        for <linux-mm@kvack.org>; Wed, 17 Feb 2016 16:47:00 -0800 (PST)
Received: from mail-ob0-x235.google.com (mail-ob0-x235.google.com. [2607:f8b0:4003:c01::235])
        by mx.google.com with ESMTPS id y9si4886056oek.73.2016.02.17.16.46.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Feb 2016 16:46:59 -0800 (PST)
Received: by mail-ob0-x235.google.com with SMTP id wb13so42946272obb.1
        for <linux-mm@kvack.org>; Wed, 17 Feb 2016 16:46:59 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <56C4FA01.2070008@sr71.net>
References: <20160212210152.9CAD15B0@viggo.jf.intel.com> <20160212210240.CB4BB5CA@viggo.jf.intel.com>
 <CAGXu5j+L6W17wkKNdheUQQ01bJE4ZXLDiG=5JBaNWju2j9NB2Q@mail.gmail.com>
 <CALCETrVUifty6QuXo67zt9DuxsgUPTqzFbaKGS0qXd75jAb35Q@mail.gmail.com> <56C4FA01.2070008@sr71.net>
From: Andy Lutomirski <luto@amacapital.net>
Date: Wed, 17 Feb 2016 16:46:39 -0800
Message-ID: <CALCETrV7t7Dc9UjNzhwN-MSO1Z0005dypOYFSt8FBzpNQcTEgA@mail.gmail.com>
Subject: Re: [PATCH 33/33] x86, pkeys: execute-only support
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: Kees Cook <keescook@google.com>, Dave Hansen <dave.hansen@linux.intel.com>, X86 ML <x86@kernel.org>, Linux-MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>

On Wed, Feb 17, 2016 at 2:53 PM, Dave Hansen <dave@sr71.net> wrote:
> On 02/17/2016 02:17 PM, Andy Lutomirski wrote:
>>> > Is there a way to detect this feature's availability without userspace
>>> > having to set up a segv handler and attempting to read a
>>> > PROT_EXEC-only region? (i.e. cpu flag for protection keys, or a way to
>>> > check the protection to see if PROT_READ got added automatically,
>>> > etc?)
>>> >
>> We could add an HWCAP.
>
> I'll bite.  What's an HWCAP?

It's a CPU capability vector that's passed to every program as an auxv
entry.  On x86, ELF_HWCAP is useless (it's already fully used up for
pointless purposes for CPUID stuff), but ELF_HWCAP2 could be added and
a bit could be defined like HWCAP2_PROT_EXEC_ONLY.

Some day, WRFSBASE, etc will be advertised via ELF_HWCAP2, I suspect.

--Andy

-- 
Andy Lutomirski
AMA Capital Management, LLC

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

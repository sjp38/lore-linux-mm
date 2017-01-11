Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id DF61A6B0033
	for <linux-mm@kvack.org>; Wed, 11 Jan 2017 16:46:05 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id f144so2359710pfa.3
        for <linux-mm@kvack.org>; Wed, 11 Jan 2017 13:46:05 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id k30si6951673pgn.247.2017.01.11.13.46.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Jan 2017 13:46:04 -0800 (PST)
Date: Wed, 11 Jan 2017 13:46:03 -0800
From: Andi Kleen <ak@linux.intel.com>
Subject: Re: [RFC, PATCHv2 29/29] mm, x86: introduce RLIMIT_VADDR
Message-ID: <20170111214603.GF8388@tassilo.jf.intel.com>
References: <20170105192910.q26ozg4ci4i3j2ai@black.fi.intel.com>
 <161ece66-fbf4-cb89-3da6-91b4851af69f@intel.com>
 <CALCETrUQ2+P424d9MW-Dy2yQ0+EnMfBuY80wd8NkNmc8is0AUw@mail.gmail.com>
 <978d5f1a-ec4d-f747-93fd-27ecfe10cb88@intel.com>
 <20170111142904.GD4895@node.shutemov.name>
 <CALCETrUn=KNdOnoRYd8GcnXPNDHAhGkaMaHRTAri4o92FSC1qg@mail.gmail.com>
 <20170111183750.GE4895@node.shutemov.name>
 <0a6f1ee4-e260-ae7b-3d39-c53f6bed8102@intel.com>
 <CALCETrXDbkotCZ1WEbhNeYGt0zyKT42agzsFxT2SZJ4wadEnQA@mail.gmail.com>
 <CA+55aFyhva9bw48G669z4QfJXjjJA5s+necfWmYoAB6eyzea=A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFyhva9bw48G669z4QfJXjjJA5s+necfWmYoAB6eyzea=A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andy Lutomirski <luto@amacapital.net>, Dave Hansen <dave.hansen@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, X86 ML <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>, linux-arch <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On Wed, Jan 11, 2017 at 11:31:25AM -0800, Linus Torvalds wrote:
> On Wed, Jan 11, 2017 at 11:20 AM, Andy Lutomirski <luto@amacapital.net> wrote:
> >
> > Taking a step back, I think it would be fantastic if we could find a
> > way to make this work without any inheritable settings at all.
> > Perhaps we could have a per-mm value that is initialized to 2^47-1 on
> > execve() and can be raised by ELF note or by prctl()?
> 
> I definitely think this is the right model. No inheritable settings,
> no suid issues, no worries. Make people who want the large address
> space (and there aren't going to be a lot of them) just mark their
> binaries at compile time.

Compile time is inconvenient if you want to test some existing
random binary if it works.

I tried to write a tool which patched ELF notes into binaries
some time ago for another project, but it ran into difficulties
and didn't work everywhere.

An inheritance scheme is much nicer for such use cases.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 34D946B025F
	for <linux-mm@kvack.org>; Thu, 14 Jul 2016 04:07:06 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id o80so50891576wme.1
        for <linux-mm@kvack.org>; Thu, 14 Jul 2016 01:07:06 -0700 (PDT)
Received: from mail-wm0-x241.google.com (mail-wm0-x241.google.com. [2a00:1450:400c:c09::241])
        by mx.google.com with ESMTPS id y193si32166939wmy.53.2016.07.14.01.07.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Jul 2016 01:07:04 -0700 (PDT)
Received: by mail-wm0-x241.google.com with SMTP id i5so8556392wmg.2
        for <linux-mm@kvack.org>; Thu, 14 Jul 2016 01:07:04 -0700 (PDT)
Date: Thu, 14 Jul 2016 10:07:01 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 6/9] x86, pkeys: add pkey set/get syscalls
Message-ID: <20160714080701.GA14613@gmail.com>
References: <20160708071810.GA27457@gmail.com>
 <577FD587.6050101@sr71.net>
 <20160709083715.GA29939@gmail.com>
 <CALCETrXJhVz6Za4=oidiM2Vfbb+XdggFBYiVyvOCcia+w064aQ@mail.gmail.com>
 <5783AE8F.3@sr71.net>
 <CALCETrW1qLZE_cq1CvmLkdnFyKRWVZuah29xERTC7o0eZ8DbwQ@mail.gmail.com>
 <5783BFB0.70203@intel.com>
 <CALCETrUZeZ00sFrTEqWSB-OxkCzGQxknmPTvFe4bv5mKc3hE+Q@mail.gmail.com>
 <20160713075550.GA515@gmail.com>
 <CALCETrUxL2ZAn8-GDtpwQPhLeNRXXp7RM1EVX2JExE+gkWGj3g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrUxL2ZAn8-GDtpwQPhLeNRXXp7RM1EVX2JExE+gkWGj3g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Dave Hansen <dave.hansen@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Dave Hansen <dave.hansen@linux.intel.com>, Al Viro <viro@zeniv.linux.org.uk>, X86 ML <x86@kernel.org>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Linux API <linux-api@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>, Linus Torvalds <torvalds@linux-foundation.org>, linux-arch <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Arnd Bergmann <arnd@arndb.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "H. Peter Anvin" <hpa@zytor.com>


* Andy Lutomirski <luto@amacapital.net> wrote:

> On Wed, Jul 13, 2016 at 12:56 AM, Ingo Molnar <mingo@kernel.org> wrote:
> >
> > * Andy Lutomirski <luto@amacapital.net> wrote:
> >
> >> > If we push a PKRU value into a thread between the rdpkru() and wrpkru(), we'll
> >> > lose the content of that "push".  I'm not sure there's any way to guarantee
> >> > this with a user-controlled register.
> >>
> >> We could try to insist that user code uses some vsyscall helper that tracks
> >> which bits are as-yet-unassigned.  That's quite messy, though.
> >
> > Actually, if we turned the vDSO into something more like a minimal user-space 
> > library with the ability to run at process startup as well to prepare stuff 
> > then it's painful to get right only *once*, and there will be tons of other 
> > areas where a proper per thread data storage on the user-space side would be 
> > immensely useful!
> 
> Doing this could be tricky: how exactly is the vDSO supposed to find per-thread 
> data without breaking existing glibc?

So I think the way this could be done is by allocating it itself. The vDSO vma 
itself is 'external' to glibc as well to begin with - this would be a small 
extension to that concept.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

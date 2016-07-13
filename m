Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 835C26B0253
	for <linux-mm@kvack.org>; Wed, 13 Jul 2016 03:56:25 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id x83so28710335wma.2
        for <linux-mm@kvack.org>; Wed, 13 Jul 2016 00:56:25 -0700 (PDT)
Received: from mail-wm0-x234.google.com (mail-wm0-x234.google.com. [2a00:1450:400c:c09::234])
        by mx.google.com with ESMTPS id b190si15699180wmf.127.2016.07.13.00.56.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jul 2016 00:56:23 -0700 (PDT)
Received: by mail-wm0-x234.google.com with SMTP id i5so55555990wmg.0
        for <linux-mm@kvack.org>; Wed, 13 Jul 2016 00:56:23 -0700 (PDT)
Date: Wed, 13 Jul 2016 09:56:05 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 6/9] x86, pkeys: add pkey set/get syscalls
Message-ID: <20160713075550.GA515@gmail.com>
References: <20160707144508.GZ11498@techsingularity.net>
 <577E924C.6010406@sr71.net>
 <20160708071810.GA27457@gmail.com>
 <577FD587.6050101@sr71.net>
 <20160709083715.GA29939@gmail.com>
 <CALCETrXJhVz6Za4=oidiM2Vfbb+XdggFBYiVyvOCcia+w064aQ@mail.gmail.com>
 <5783AE8F.3@sr71.net>
 <CALCETrW1qLZE_cq1CvmLkdnFyKRWVZuah29xERTC7o0eZ8DbwQ@mail.gmail.com>
 <5783BFB0.70203@intel.com>
 <CALCETrUZeZ00sFrTEqWSB-OxkCzGQxknmPTvFe4bv5mKc3hE+Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrUZeZ00sFrTEqWSB-OxkCzGQxknmPTvFe4bv5mKc3hE+Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Dave Hansen <dave.hansen@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Dave Hansen <dave.hansen@linux.intel.com>, Al Viro <viro@zeniv.linux.org.uk>, X86 ML <x86@kernel.org>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Linux API <linux-api@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>, Linus Torvalds <torvalds@linux-foundation.org>, linux-arch <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Arnd Bergmann <arnd@arndb.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "H. Peter Anvin" <hpa@zytor.com>


* Andy Lutomirski <luto@amacapital.net> wrote:

> > If we push a PKRU value into a thread between the rdpkru() and wrpkru(), we'll 
> > lose the content of that "push".  I'm not sure there's any way to guarantee 
> > this with a user-controlled register.
> 
> We could try to insist that user code uses some vsyscall helper that tracks 
> which bits are as-yet-unassigned.  That's quite messy, though.

Actually, if we turned the vDSO into something more like a minimal user-space 
library with the ability to run at process startup as well to prepare stuff then 
it's painful to get right only *once*, and there will be tons of other areas where 
a proper per thread data storage on the user-space side would be immensely useful!

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

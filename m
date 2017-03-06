Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id EB8806B0387
	for <linux-mm@kvack.org>; Mon,  6 Mar 2017 13:42:28 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id u9so28432019wme.6
        for <linux-mm@kvack.org>; Mon, 06 Mar 2017 10:42:28 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id m26si10833574wrb.16.2017.03.06.10.42.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Mon, 06 Mar 2017 10:42:27 -0800 (PST)
Date: Mon, 6 Mar 2017 19:42:05 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCHv4 00/33] 5-level paging
In-Reply-To: <CA+55aFypZza_L5jyDEFwBrFZPR72R18RwTMz4TuV5sg0H4aaqA@mail.gmail.com>
Message-ID: <alpine.DEB.2.20.1703061935220.3771@nanos>
References: <20170306135357.3124-1-kirill.shutemov@linux.intel.com> <CA+55aFypZza_L5jyDEFwBrFZPR72R18RwTMz4TuV5sg0H4aaqA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, the arch/x86 maintainers <x86@kernel.org>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Mon, 6 Mar 2017, Linus Torvalds wrote:

> On Mon, Mar 6, 2017 at 5:53 AM, Kirill A. Shutemov
> <kirill.shutemov@linux.intel.com> wrote:
> > Here is v4 of 5-level paging patchset. Please review and consider applying.
> 
> I think we should just aim for this being in 4.12. I don't see any
> real reason to delay merging it, the main question in my mind is which
> tree it would go through. A separate x86 -tip branch, or Andrew's mm
> tree or me just pulling directly, or what?

We can take it through -tip and I prefer to do so as there are other
changes in the page table code lurking.

We probably need to split it apart:

   - Apply the mm core only parts to a branch which can be pulled into
     Andrews mm-tree

   - Base the x86 changes on top of it

So both worlds can work on top of the mm core parts (almost
independently). From what I have seen so far, it's more likely that we get
delta changes/fixes on the x86 side than on the mm core side. And if we get
changes on the mm core side, we can deal with that via the seperate mm core
branch.

Andrew, does that work for you?

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

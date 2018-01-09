Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id C27FB6B0038
	for <linux-mm@kvack.org>; Mon,  8 Jan 2018 19:13:07 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id f132so4395162wmf.6
        for <linux-mm@kvack.org>; Mon, 08 Jan 2018 16:13:07 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k19sor6583600ede.24.2018.01.08.16.13.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 08 Jan 2018 16:13:06 -0800 (PST)
Date: Tue, 9 Jan 2018 03:13:03 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 4.14 023/159] mm/sparsemem: Allocate mem_section at
 runtime for CONFIG_SPARSEMEM_EXTREME=y
Message-ID: <20180109001303.dy73bpixsaegn4ol@node.shutemov.name>
References: <20171222084623.668990192@linuxfoundation.org>
 <20171222084625.007160464@linuxfoundation.org>
 <1515302062.6507.18.camel@gmx.de>
 <20180108160444.2ol4fvgqbxnjmlpg@gmail.com>
 <20180108174653.7muglyihpngxp5tl@black.fi.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180108174653.7muglyihpngxp5tl@black.fi.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>, Mike Galbraith <efault@gmx.de>, Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org, stable@vger.kernel.org, Andy Lutomirski <luto@amacapital.net>, Borislav Petkov <bp@suse.de>, Cyrill Gorcunov <gorcunov@openvz.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, linux-mm@kvack.org, Dave Young <dyoung@redhat.com>, Baoquan He <bhe@redhat.com>, Vivek Goyal <vgoyal@redhat.com>, kexec@lists.infradead.org

On Mon, Jan 08, 2018 at 08:46:53PM +0300, Kirill A. Shutemov wrote:
> On Mon, Jan 08, 2018 at 04:04:44PM +0000, Ingo Molnar wrote:
> > 
> > hi Kirill,
> > 
> > As Mike reported it below, your 5-level paging related upstream commit 
> > 83e3c48729d9 and all its followup fixes:
> > 
> >  83e3c48729d9: mm/sparsemem: Allocate mem_section at runtime for CONFIG_SPARSEMEM_EXTREME=y
> >  629a359bdb0e: mm/sparsemem: Fix ARM64 boot crash when CONFIG_SPARSEMEM_EXTREME=y
> >  d09cfbbfa0f7: mm/sparse.c: wrong allocation for mem_section
> > 
> > ... still breaks kexec - and that now regresses -stable as well.
> > 
> > Given that 5-level paging now syntactically depends on having this commit, if we 
> > fully revert this then we'll have to disable 5-level paging as well.

This *should* help.

Mike, could you test this? (On top of the rest of the fixes.)

Sorry for the mess.

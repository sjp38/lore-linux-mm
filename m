Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7B4D46B0389
	for <linux-mm@kvack.org>; Tue,  7 Mar 2017 04:33:14 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id u48so72534434wrc.0
        for <linux-mm@kvack.org>; Tue, 07 Mar 2017 01:33:14 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id b109si29966586wrd.317.2017.03.07.01.33.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 07 Mar 2017 01:33:13 -0800 (PST)
Date: Tue, 7 Mar 2017 10:32:53 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCHv4 00/33] 5-level paging
In-Reply-To: <20170307114115.768312f4@canb.auug.org.au>
Message-ID: <alpine.DEB.2.20.1703071032040.3584@nanos>
References: <20170306135357.3124-1-kirill.shutemov@linux.intel.com> <CA+55aFypZza_L5jyDEFwBrFZPR72R18RwTMz4TuV5sg0H4aaqA@mail.gmail.com> <alpine.DEB.2.20.1703061935220.3771@nanos> <20170307114115.768312f4@canb.auug.org.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, the arch/x86 maintainers <x86@kernel.org>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Tue, 7 Mar 2017, Stephen Rothwell wrote:
> Hi Thomas,
> 
> On Mon, 6 Mar 2017 19:42:05 +0100 (CET) Thomas Gleixner <tglx@linutronix.de> wrote:
> >
> > We probably need to split it apart:
> > 
> >    - Apply the mm core only parts to a branch which can be pulled into
> >      Andrews mm-tree
> 
> Andrew's mm-tree is not a git tree it is a quilt series ...

I know, but creating a 'mm-base-5-level.patch' from a git branch is trivial
enough.

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

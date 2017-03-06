Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1E1A06B0388
	for <linux-mm@kvack.org>; Mon,  6 Mar 2017 14:09:16 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id v66so68657917wrc.4
        for <linux-mm@kvack.org>; Mon, 06 Mar 2017 11:09:16 -0800 (PST)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id r5si27645000wrc.97.2017.03.06.11.09.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Mar 2017 11:09:14 -0800 (PST)
Received: by mail-wm0-x244.google.com with SMTP id u132so7292074wmg.1
        for <linux-mm@kvack.org>; Mon, 06 Mar 2017 11:09:14 -0800 (PST)
Date: Mon, 6 Mar 2017 22:09:11 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv4 00/33] 5-level paging
Message-ID: <20170306190911.GB27719@node.shutemov.name>
References: <20170306135357.3124-1-kirill.shutemov@linux.intel.com>
 <CA+55aFypZza_L5jyDEFwBrFZPR72R18RwTMz4TuV5sg0H4aaqA@mail.gmail.com>
 <alpine.DEB.2.20.1703061935220.3771@nanos>
 <CA+55aFyL7UDP4AyscTOO=pxYuFG2GkG_rbEPgqBMBwkEi7t3vw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFyL7UDP4AyscTOO=pxYuFG2GkG_rbEPgqBMBwkEi7t3vw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, the arch/x86 maintainers <x86@kernel.org>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Mon, Mar 06, 2017 at 11:03:56AM -0800, Linus Torvalds wrote:
> On Mon, Mar 6, 2017 at 10:42 AM, Thomas Gleixner <tglx@linutronix.de> wrote:
> >
> > We probably need to split it apart:
> >
> >    - Apply the mm core only parts to a branch which can be pulled into
> >      Andrews mm-tree
> >
> >    - Base the x86 changes on top of it
> 
> I'll happily take some of the preparatory patches for 4.11 too. Some
> of them just don't seem to have any downside. The cpuid stuff, and the
> basic scaffolding we could easily merge early. That includes the dummy
> 5level code, ie "5level-fixup.h" and even some of the mm side that
> doesn't actually change anything and just prepares for the real code.

The first 7 patches are relatively low-risk. It would be nice to have them
in earlier.

I'm commited to address any possible drawbacks quickly if you considering
applying it into v4.11.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

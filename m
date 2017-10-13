Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9B0206B0033
	for <linux-mm@kvack.org>; Fri, 13 Oct 2017 11:37:41 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id f15so15552936qtf.1
        for <linux-mm@kvack.org>; Fri, 13 Oct 2017 08:37:41 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q72si1019209qka.229.2017.10.13.08.37.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Oct 2017 08:37:40 -0700 (PDT)
Date: Fri, 13 Oct 2017 10:37:35 -0500
From: Josh Poimboeuf <jpoimboe@redhat.com>
Subject: Re: [lkp-robot] [x86/kconfig]  81d3871900:
 BUG:unable_to_handle_kernel
Message-ID: <20171013153735.yywauekabxnczg74@treble>
References: <20171010121513.GC5445@yexl-desktop>
 <20171011023106.izaulhwjcoam55jt@treble>
 <20171011170120.7flnk6r77dords7a@treble>
 <alpine.DEB.2.20.1710121202210.28556@nuc-kabylake>
 <20171013044521.662ck56gkwaw3xog@treble>
 <alpine.DEB.2.20.1710131021240.3949@nuc-kabylake>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1710131021240.3949@nuc-kabylake>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: kernel test robot <xiaolong.ye@intel.com>, Ingo Molnar <mingo@kernel.org>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Denys Vlasenko <dvlasenk@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Jiri Slaby <jslaby@suse.cz>, Linus Torvalds <torvalds@linux-foundation.org>, Mike Galbraith <efault@gmx.de>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, LKML <linux-kernel@vger.kernel.org>, lkp@01.org, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>

On Fri, Oct 13, 2017 at 10:22:54AM -0500, Christopher Lameter wrote:
> On Thu, 12 Oct 2017, Josh Poimboeuf wrote:
> 
> > > Can you run SLUB with full debug? specify slub_debug on the commandline or
> > > set CONFIG_SLUB_DEBUG_ON
> >
> > Oddly enough, with CONFIG_SLUB+slub_debug, I get the same crypto panic I
> > got with CONFIG_SLOB.  The trapping instruction is:
> >
> >   vmovdqa 0x140(%rdi),%xmm0
> >
> > I'll try to bisect it tomorrow.  It at least goes back to v4.10.  I'm
> > not really sure whether this panic is related to SLUB or SLOB at all.
> 
> Guess not. The slab allocators can fail if the metadata gets corrupted.
> That is why we have extensive debug modes so we can find who is to blame
> for corruptions.
> 
> > (Though the original panic reported upthread by the kernel test robot
> > *does* look SLOB related.)
> 
> Yup. Just happened to be configured for SLOB then.

Just to clarify, the upthread panic in SLOB is *not* related to the
crypto issue.  So somebody still needs to look at that one:

  https://lkml.kernel.org/r/20171010121513.GC5445@yexl-desktop

-- 
Josh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

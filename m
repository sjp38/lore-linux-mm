From: Christopher Lameter <cl@linux.com>
Subject: Re: [lkp-robot] [x86/kconfig]  81d3871900:
 BUG:unable_to_handle_kernel
Date: Fri, 13 Oct 2017 10:22:54 -0500 (CDT)
Message-ID: <alpine.DEB.2.20.1710131021240.3949@nuc-kabylake>
References: <20171010121513.GC5445@yexl-desktop> <20171011023106.izaulhwjcoam55jt@treble> <20171011170120.7flnk6r77dords7a@treble> <alpine.DEB.2.20.1710121202210.28556@nuc-kabylake> <20171013044521.662ck56gkwaw3xog@treble>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171013044521.662ck56gkwaw3xog@treble>
Sender: linux-kernel-owner@vger.kernel.org
To: Josh Poimboeuf <jpoimboe@redhat.com>
Cc: kernel test robot <xiaolong.ye@intel.com>, Ingo Molnar <mingo@kernel.org>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Denys Vlasenko <dvlasenk@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Jiri Slaby <jslaby@suse.cz>, Linus Torvalds <torvalds@linux-foundation.org>, Mike Galbraith <efault@gmx.de>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, LKML <linux-kernel@vger.kernel.org>, lkp@01.org, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
List-Id: linux-mm.kvack.org

On Thu, 12 Oct 2017, Josh Poimboeuf wrote:

> > Can you run SLUB with full debug? specify slub_debug on the commandline or
> > set CONFIG_SLUB_DEBUG_ON
>
> Oddly enough, with CONFIG_SLUB+slub_debug, I get the same crypto panic I
> got with CONFIG_SLOB.  The trapping instruction is:
>
>   vmovdqa 0x140(%rdi),%xmm0
>
> I'll try to bisect it tomorrow.  It at least goes back to v4.10.  I'm
> not really sure whether this panic is related to SLUB or SLOB at all.

Guess not. The slab allocators can fail if the metadata gets corrupted.
That is why we have extensive debug modes so we can find who is to blame
for corruptions.

> (Though the original panic reported upthread by the kernel test robot
> *does* look SLOB related.)

Yup. Just happened to be configured for SLOB then.

From: Christopher Lameter <cl@linux.com>
Subject: Re: [lkp-robot] [x86/kconfig]  81d3871900:
 BUG:unable_to_handle_kernel
Date: Thu, 12 Oct 2017 12:05:04 -0500 (CDT)
Message-ID: <alpine.DEB.2.20.1710121202210.28556@nuc-kabylake>
References: <20171010121513.GC5445@yexl-desktop> <20171011023106.izaulhwjcoam55jt@treble> <20171011170120.7flnk6r77dords7a@treble>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171011170120.7flnk6r77dords7a@treble>
Sender: linux-kernel-owner@vger.kernel.org
To: Josh Poimboeuf <jpoimboe@redhat.com>
Cc: kernel test robot <xiaolong.ye@intel.com>, Ingo Molnar <mingo@kernel.org>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Denys Vlasenko <dvlasenk@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Jiri Slaby <jslaby@suse.cz>, Linus Torvalds <torvalds@linux-foundation.org>, Mike Galbraith <efault@gmx.de>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, LKML <linux-kernel@vger.kernel.org>, lkp@01.org, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
List-Id: linux-mm.kvack.org

On Wed, 11 Oct 2017, Josh Poimboeuf wrote:

> I failed to add the slab maintainers to CC on the last attempt.  Trying
> again.


Hmmm... Yea. SLOB is rarely used and tested. Good illustration of a simple
allocator and the K&R mechanism that was used in the early kernels.

> > Adding the slub maintainers.  Is slob still supposed to work?

Have not seen anyone using it in a decade or so.

Does the same config with SLUB and slub_debug on the commandline run
cleanly?

> > I have no idea how that crypto panic could could be related to slob, but
> > at least it goes away when I switch to slub.

Can you run SLUB with full debug? specify slub_debug on the commandline or
set CONFIG_SLUB_DEBUG_ON

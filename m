From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v2 3/3] x86/mm: If INVPCID is available, use it to flush
 global mappings
Date: Fri, 29 Jan 2016 19:27:17 +0100
Message-ID: <20160129182717.GA17459@pd.tnic>
References: <cover.1453746505.git.luto@kernel.org>
 <e3e4f31df42ea5d5e190a6d1e300e01d55e09d79.1453746505.git.luto@kernel.org>
 <20160129142625.GH10187@pd.tnic>
 <CALCETrWhUWjfdDS6eyB6PfrJLU8YvvrfkeeKFTo8moxq7L5t6A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CALCETrWhUWjfdDS6eyB6PfrJLU8YvvrfkeeKFTo8moxq7L5t6A@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Andy Lutomirski <luto@amacapital.net>
Cc: Andy Lutomirski <luto@kernel.org>, X86 ML <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Brian Gerst <brgerst@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>
List-Id: linux-mm.kvack.org

On Fri, Jan 29, 2016 at 09:35:22AM -0800, Andy Lutomirski wrote:
> I'll fiddle with that benchmark a little bit.  Maybe I can make it
> suck less.  If anyone knows a good non-micro benchmark for this, let
> me know.

Yeah, I don't know of a good one. The TLB and all those intermediary
walker caches modern x86 CPUs have are really good. So it is hard to
measure any improvements there. I guess in this particular case, if one
can't measure slowdowns and the code is simple enough, then we're good
enough. In theory, we are carefully killing less TLB entries and the
related cached page walker data so that should be a good thing...

> I refuse to use dbus as my benchmark :)

Ha!

> FWIW, I benchmarked cr4 vs invpcid by adding a prctl and calling it in
> a loop.

Apparently INVPCID is faster than the two CR4 writes.

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.

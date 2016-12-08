From: Borislav Petkov <bp@alien8.de>
Subject: Re: [RFC, PATCHv1 15/28] x86: detect 5-level paging support
Date: Thu, 8 Dec 2016 21:20:13 +0100
Message-ID: <20161208202013.uutsny6avn5gimwq@pd.tnic>
References: <20161208162150.148763-1-kirill.shutemov@linux.intel.com>
 <20161208162150.148763-17-kirill.shutemov@linux.intel.com>
 <20161208200505.c6xiy56oufg6d24m@pd.tnic>
 <CA+55aFzgp+6c6RhgYvEjor=_+ewMeYL4XY4BqER5HMUknXBDCA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Return-path: <linux-arch-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CA+55aFzgp+6c6RhgYvEjor=_+ewMeYL4XY4BqER5HMUknXBDCA@mail.gmail.com>
Sender: linux-arch-owner@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, the arch/x86 maintainers <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

On Thu, Dec 08, 2016 at 12:08:53PM -0800, Linus Torvalds wrote:
> Especially since that's some of the ugliest inline asm ever due to the
> nasty BX handling.

Yeah, about that: why doesn't gcc handle that for us like it would
handle a clobbered register? I mean, it *should* know that BX is live
when building with -fPIC... The .ifnc thing looks really silly.

Hmmm.

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

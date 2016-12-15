From: Borislav Petkov <bp@alien8.de>
Subject: Re: [RFC, PATCHv1 15/28] x86: detect 5-level paging support
Date: Thu, 15 Dec 2016 20:09:02 +0100
Message-ID: <20161215190902.tdle4uj27xkc3x4i@pd.tnic>
References: <20161208162150.148763-1-kirill.shutemov@linux.intel.com>
 <20161208162150.148763-17-kirill.shutemov@linux.intel.com>
 <20161208200505.c6xiy56oufg6d24m@pd.tnic>
 <CA+55aFzgp+6c6RhgYvEjor=_+ewMeYL4XY4BqER5HMUknXBDCA@mail.gmail.com>
 <20161208202013.uutsny6avn5gimwq@pd.tnic>
 <b393a48a-6e8b-6427-373c-2825641fea99@zytor.com>
 <BD4BD1C9-F6FD-4905-9B09-059284FD2713@alien8.de>
 <20161215143944.ruxr6r3b2atg4tnf@pd.tnic>
 <E77F6B05-4F69-4C02-90B4-A8A6D0D392DE@zytor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Return-path: <linux-arch-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <E77F6B05-4F69-4C02-90B4-A8A6D0D392DE@zytor.com>
Sender: linux-arch-owner@vger.kernel.org
To: hpa@zytor.com
Cc: Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, the arch/x86 maintainers <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

On Thu, Dec 15, 2016 at 09:52:12AM -0800, hpa@zytor.com wrote:
> This really is only worthwhile if it ends up producing better code,
> but I doubt it.

Nah, the most it does is drops those ifnc lines in there on newer gccs.

They will appear only on
		gcc-4 and earlier and
		if we're -fPIC and
		if we're -m32 and
		if we have enough register pressure to force gcc to use the PIC	register

It was a good exercise for me to see in detail how would I go about
doing a gcc-specific workaround.

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

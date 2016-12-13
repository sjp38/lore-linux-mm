From: Boris Petkov <bp@alien8.de>
Subject: Re: [RFC, PATCHv1 15/28] x86: detect 5-level paging support
Date: Wed, 14 Dec 2016 00:07:54 +0100
Message-ID: <BD4BD1C9-F6FD-4905-9B09-059284FD2713@alien8.de>
References: <20161208162150.148763-1-kirill.shutemov@linux.intel.com> <20161208162150.148763-17-kirill.shutemov@linux.intel.com> <20161208200505.c6xiy56oufg6d24m@pd.tnic> <CA+55aFzgp+6c6RhgYvEjor=_+ewMeYL4XY4BqER5HMUknXBDCA@mail.gmail.com> <20161208202013.uutsny6avn5gimwq@pd.tnic> <b393a48a-6e8b-6427-373c-2825641fea99@zytor.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 8bit
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <b393a48a-6e8b-6427-373c-2825641fea99@zytor.com>
Sender: linux-kernel-owner@vger.kernel.org
To: "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, the arch/x86 maintainers <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

On December 13, 2016 11:44:06 PM GMT+01:00, "H. Peter Anvin" <hpa@zytor.com> wrote:
>When compiling with -fPIC gcc treats ebx as a "fixed register".  A
>fixed
>register can't be spilled, and so a clobber of a fixed register is a
>fatal error.
>
>Like it or not, it's how it works.
>
>	-hpa

In the meantime I talked to my gcc guy and here's the deal:

There are gcc versions (4.x and earlier) which do not save/restore the PIC register around an inline asm even if it is one of the registers that the inline asm clobbers. Therefore the saving/restoring needs to be done by the inline asm itself.

5.x and later handle that fine.

Thus I was thinking of adding a build-time check for the gcc version but that might turn out to be more code in the end than those ugly ifnc clauses. 
-- 
Sent from a small device: formatting sux and brevity is inevitable. 

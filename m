From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH 05/30] x86, kaiser: prepare assembly for entry/exit CR3
 switching
Date: Thu, 9 Nov 2017 14:20:16 +0100
Message-ID: <20171109132016.ntku742dgppt7k4v@pd.tnic>
References: <20171108194646.907A1942@viggo.jf.intel.com>
 <20171108194654.B960A09E@viggo.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20171108194654.B960A09E@viggo.jf.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, x86@kernel.org
List-Id: linux-mm.kvack.org

On Wed, Nov 08, 2017 at 11:46:54AM -0800, Dave Hansen wrote:
> From: Dave Hansen <dave.hansen@linux.intel.com>
> 
> This is largely code from Andy Lutomirski.  I fixed a few bugs
> in it, and added a few SWITCH_TO_* spots.

...

> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
> Cc: Moritz Lipp <moritz.lipp@iaik.tugraz.at>
> Cc: Daniel Gruss <daniel.gruss@iaik.tugraz.at>
> Cc: Michael Schwarz <michael.schwarz@iaik.tugraz.at>
> Cc: Richard Fellner <richard.fellner@student.tugraz.at>
> Cc: Andy Lutomirski <luto@kernel.org>
> Cc: Linus Torvalds <torvalds@linux-foundation.org>
> Cc: Kees Cook <keescook@google.com>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: x86@kernel.org
> ---
> 
>  b/arch/x86/entry/calling.h         |   65 +++++++++++++++++++++++++++++++++++++
>  b/arch/x86/entry/entry_64.S        |   30 ++++++++++++++---
>  b/arch/x86/entry/entry_64_compat.S |    8 ++++
>  3 files changed, 98 insertions(+), 5 deletions(-)

What branch is that one against?

It doesn't apply cleanly against tip:x86/asm from today:

patching file arch/x86/entry/calling.h
Hunk #1 succeeded at 2 with fuzz 1 (offset 1 line).
Hunk #2 succeeded at 188 (offset 1 line).
patching file arch/x86/entry/entry_64_compat.S
Hunk #1 succeeded at 92 (offset 1 line).
Hunk #2 succeeded at 218 (offset 1 line).
Hunk #3 succeeded at 246 (offset 1 line).
Hunk #4 FAILED at 330.
1 out of 4 hunks FAILED -- saving rejects to file arch/x86/entry/entry_64_compat.S.rej
patching file arch/x86/entry/entry_64.S
Hunk #1 succeeded at 148 (offset 1 line).
Hunk #2 succeeded at 168 (offset 1 line).
Hunk #3 succeeded at 508 with fuzz 2 (offset 163 lines).
Hunk #4 FAILED at 685.
Hunk #5 succeeded at 1119 (offset -54 lines).
Hunk #6 succeeded at 1145 (offset -54 lines).
Hunk #7 succeeded at 1174 (offset -54 lines).
Hunk #8 succeeded at 1223 (offset -54 lines).
Hunk #9 succeeded at 1350 (offset -54 lines).
Hunk #10 succeeded at 1575 (offset -54 lines).
1 out of 10 hunks FAILED -- saving rejects to file arch/x86/entry/entry_64.S.rej

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

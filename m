From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v3 0/3] x86/mm: INVPCID support
Date: Mon, 1 Feb 2016 11:51:32 +0100
Message-ID: <20160201105132.GB6438@pd.tnic>
References: <cover.1454096309.git.luto@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <cover.1454096309.git.luto@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@kernel.org>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, Brian Gerst <brgerst@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>
List-Id: linux-mm.kvack.org

On Fri, Jan 29, 2016 at 11:42:56AM -0800, Andy Lutomirski wrote:
> Boris, I think you already have these prerequisites queued up:
> 
> http://lkml.kernel.org/g/1452516679-32040-2-git-send-email-aryabinin@virtuozzo.com
> http://lkml.kernel.org/g/1452516679-32040-3-git-send-email-aryabinin@virtuozzo.com
> 
> This is a straightforward speedup on Ivy Bridge and newer, IIRC.
> (I tested on Skylake.  INVPCID is not available on Sandy Bridge.
> I don't have Ivy Bridge, Haswell or Broadwell to test on, so I
> could be wrong as to when the feature was introduced.)
> 
> I think we should consider these patches separately from the rest
> of the PCID stuff -- they barely interact, and this part is much
> simpler and is useful on its own.
> 
> Changes from v2:
>  - Add macros for the INVPCID mode numbers.
>  - Add a changelog message for the chicken bit.
> 
> v1 was exactly identical to patches 2-4 of the PCID RFC series.
> Andy Lutomirski (3):
>   x86/mm: Add INVPCID helpers
>   x86/mm: Add a noinvpcid option to turn off INVPCID
>   x86/mm: If INVPCID is available, use it to flush global mappings
> 
>  Documentation/kernel-parameters.txt |  2 ++
>  arch/x86/include/asm/tlbflush.h     | 57 +++++++++++++++++++++++++++++++++++++
>  arch/x86/kernel/cpu/common.c        | 16 +++++++++++
>  3 files changed, 75 insertions(+)

All 5 (3 INVPCID + 2 KASAN ones at the URLs above):

Reviewed-by: Borislav Petkov <bp@suse.de>

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.

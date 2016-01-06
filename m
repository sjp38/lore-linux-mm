From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v7 1/3] x86: Add classes to exception tables
Date: Wed, 6 Jan 2016 13:36:04 +0100
Message-ID: <20160106123604.GD19507@pd.tnic>
References: <cover.1451952351.git.tony.luck@intel.com>
 <b5dc7a1ee68f48dc61c10959b2209851f6eb6aab.1451952351.git.tony.luck@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <b5dc7a1ee68f48dc61c10959b2209851f6eb6aab.1451952351.git.tony.luck@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Tony Luck <tony.luck@intel.com>
Cc: Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dan Williams <dan.j.williams@intel.com>, elliott@hpe.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@ml01.01.org, x86@kernel.org
List-Id: linux-mm.kvack.org

On Wed, Dec 30, 2015 at 09:59:29AM -0800, Tony Luck wrote:
> Starting with a patch from Andy Lutomirski <luto@amacapital.net>
> that used linker relocation trickery to free up a couple of bits
> in the "fixup" field of the exception table (and generalized the
> uaccess_err hack to use one of the classes).
> 
> This patch allocates another one of the classes to provide
> a mechanism to provide the fault number to the fixup code
> in %rax.
> 
> Still one free class for the next brilliant idea. If more are
> needed it should be possible to squeeze another bit or three
> extending the same technique.
> 
> Originally-from: Andy Lutomirski <luto@amacapital.net>
> Signed-off-by: Tony Luck <tony.luck@intel.com>
> ---
>  arch/x86/include/asm/asm.h     | 102 +++++++++++++++++++++++++++++++----------
>  arch/x86/include/asm/uaccess.h |  17 +++++--
>  arch/x86/kernel/kprobes/core.c |   2 +-
>  arch/x86/kernel/traps.c        |   6 +--
>  arch/x86/mm/extable.c          |  66 ++++++++++++++++++--------
>  arch/x86/mm/fault.c            |   2 +-
>  6 files changed, 142 insertions(+), 53 deletions(-)

...

> @@ -699,7 +699,7 @@ static void math_error(struct pt_regs *regs, int error_code, int trapnr)
>  	conditional_sti(regs);
>  
>  	if (!user_mode(regs)) {
> -		if (!fixup_exception(regs)) {
> +		if (!fixup_exception(regs, X86_TRAP_DE)) {

Whatever we end up doing, this needs to be trapnr above and not X86_TRAP_DE.

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.

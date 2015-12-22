Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 64D426B000C
	for <linux-mm@kvack.org>; Tue, 22 Dec 2015 06:14:00 -0500 (EST)
Received: by mail-wm0-f52.google.com with SMTP id l126so104605624wml.1
        for <linux-mm@kvack.org>; Tue, 22 Dec 2015 03:14:00 -0800 (PST)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:120:8448::d00d])
        by mx.google.com with ESMTP id gk3si55925648wjd.195.2015.12.22.03.13.59
        for <linux-mm@kvack.org>;
        Tue, 22 Dec 2015 03:13:59 -0800 (PST)
Date: Tue, 22 Dec 2015 12:13:58 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCHV3 1/3] x86, ras: Add new infrastructure for machine check
 fixup tables
Message-ID: <20151222111357.GC3728@pd.tnic>
References: <cover.1450283985.git.tony.luck@intel.com>
 <2e91c18f23be90b33c2cbfff6cce6b6f50592a96.1450283985.git.tony.luck@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <2e91c18f23be90b33c2cbfff6cce6b6f50592a96.1450283985.git.tony.luck@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Luck <tony.luck@intel.com>
Cc: Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dan Williams <dan.j.williams@intel.com>, Elliott@pd.tnic, Robert <elliott@hpe.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@ml01.01.org, x86@kernel.org

On Tue, Dec 15, 2015 at 05:29:30PM -0800, Tony Luck wrote:
> Copy the existing page fault fixup mechanisms to create a new table
> to be used when fixing machine checks. Note:
> 1) At this time we only provide a macro to annotate assembly code
> 2) We assume all fixups will in code builtin to the kernel.
> 3) Only for x86_64
> 4) New code under CONFIG_MCE_KERNEL_RECOVERY (default 'n')
> 
> Signed-off-by: Tony Luck <tony.luck@intel.com>
> ---
>  arch/x86/Kconfig                  | 10 ++++++++++
>  arch/x86/include/asm/asm.h        | 10 ++++++++--
>  arch/x86/include/asm/mce.h        | 14 ++++++++++++++
>  arch/x86/kernel/cpu/mcheck/mce.c  | 16 ++++++++++++++++
>  arch/x86/kernel/vmlinux.lds.S     |  6 +++++-
>  arch/x86/mm/extable.c             | 19 +++++++++++++++++++
>  include/asm-generic/vmlinux.lds.h | 12 +++++++-----
>  7 files changed, 79 insertions(+), 8 deletions(-)

Reviewed-by: Borislav Petkov <bp@suse.de>

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

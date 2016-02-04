Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 995EE4403D8
	for <linux-mm@kvack.org>; Thu,  4 Feb 2016 08:10:54 -0500 (EST)
Received: by mail-wm0-f54.google.com with SMTP id p63so211059012wmp.1
        for <linux-mm@kvack.org>; Thu, 04 Feb 2016 05:10:54 -0800 (PST)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:120:8448::d00d])
        by mx.google.com with ESMTP id ay10si17522598wjb.181.2016.02.04.05.10.53
        for <linux-mm@kvack.org>;
        Thu, 04 Feb 2016 05:10:53 -0800 (PST)
Date: Thu, 4 Feb 2016 14:10:47 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v9 2/4] x86, mce: Check for faults tagged in
 EXTABLE_CLASS_FAULT exception table entries
Message-ID: <20160204131047.GA5343@pd.tnic>
References: <cover.1454455138.git.tony.luck@intel.com>
 <6d5ca2f80f3da2b898ac2501175ac170d746a388.1454455138.git.tony.luck@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <6d5ca2f80f3da2b898ac2501175ac170d746a388.1454455138.git.tony.luck@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Luck <tony.luck@intel.com>
Cc: Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dan Williams <dan.j.williams@intel.com>, elliott@hpe.com, Brian Gerst <brgerst@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@ml01.01.org, x86@kernel.org

On Thu, Dec 31, 2015 at 11:40:27AM -0800, Tony Luck wrote:
> Extend the severity checking code to add a new context IN_KERN_RECOV
> which is used to indicate that the machine check was triggered by code
> in the kernel with a EXTABLE_CLASS_FAULT fixup entry.
> 
> Major re-work to the tail code in do_machine_check() to make all this
> readable/maintainable. One functional change is that tolerant=3 no longer
> stops recovery actions. Revert to only skipping sending SIGBUS to the
> current process.
> 
> Signed-off-by: Tony Luck <tony.luck@intel.com>
> ---
>  arch/x86/kernel/cpu/mcheck/mce-severity.c | 23 +++++++++-
>  arch/x86/kernel/cpu/mcheck/mce.c          | 71 ++++++++++++++++---------------
>  2 files changed, 58 insertions(+), 36 deletions(-)
> 
> diff --git a/arch/x86/kernel/cpu/mcheck/mce-severity.c b/arch/x86/kernel/cpu/mcheck/mce-severity.c
> index 9c682c222071..bca8b3936740 100644
> --- a/arch/x86/kernel/cpu/mcheck/mce-severity.c
> +++ b/arch/x86/kernel/cpu/mcheck/mce-severity.c
> @@ -13,7 +13,9 @@
>  #include <linux/seq_file.h>
>  #include <linux/init.h>
>  #include <linux/debugfs.h>
> +#include <linux/module.h>

That module.h include is not needed anymore, right?

You have the same in mce.c too.

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

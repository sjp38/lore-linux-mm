Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f174.google.com (mail-lb0-f174.google.com [209.85.217.174])
	by kanga.kvack.org (Postfix) with ESMTP id 774AE6B000E
	for <linux-mm@kvack.org>; Tue, 22 Dec 2015 06:14:05 -0500 (EST)
Received: by mail-lb0-f174.google.com with SMTP id sv6so22542149lbb.0
        for <linux-mm@kvack.org>; Tue, 22 Dec 2015 03:14:05 -0800 (PST)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:120:8448::d00d])
        by mx.google.com with ESMTP id oa4si20639587lbb.204.2015.12.22.03.14.03
        for <linux-mm@kvack.org>;
        Tue, 22 Dec 2015 03:14:03 -0800 (PST)
Date: Tue, 22 Dec 2015 12:14:01 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCHV3 2/3] x86, ras: Extend machine check recovery code to
 annotated ring0 areas
Message-ID: <20151222111401.GD3728@pd.tnic>
References: <cover.1450283985.git.tony.luck@intel.com>
 <e5547404ebab8f1f6c04c371bbb33109acc9534b.1450283985.git.tony.luck@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <e5547404ebab8f1f6c04c371bbb33109acc9534b.1450283985.git.tony.luck@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Luck <tony.luck@intel.com>
Cc: Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dan Williams <dan.j.williams@intel.com>, Elliott@pd.tnic, Robert <elliott@hpe.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@ml01.01.org, x86@kernel.org

On Tue, Dec 15, 2015 at 05:29:59PM -0800, Tony Luck wrote:
> Extend the severity checking code to add a new context IN_KERN_RECOV
> which is used to indicate that the machine check was triggered by code
> in the kernel with a fixup entry.
> 
> Add code to check for this situation and respond by altering the return
> IP to the fixup address.
> 
> Major re-work to the tail code in do_machine_check() to make all this
> readable/maintainable. One functional change is that tolerant=3 no longer
> stops recovery actions. Revert to only skipping sending SIGBUS to the
> current process.
> 
> Signed-off-by: Tony Luck <tony.luck@intel.com>
> ---
>  arch/x86/kernel/cpu/mcheck/mce-severity.c | 21 +++++++++-
>  arch/x86/kernel/cpu/mcheck/mce.c          | 70 ++++++++++++++++---------------
>  2 files changed, 55 insertions(+), 36 deletions(-)

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

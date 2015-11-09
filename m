Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f169.google.com (mail-yk0-f169.google.com [209.85.160.169])
	by kanga.kvack.org (Postfix) with ESMTP id F11A36B0255
	for <linux-mm@kvack.org>; Mon,  9 Nov 2015 14:20:54 -0500 (EST)
Received: by ykfs79 with SMTP id s79so53977090ykf.1
        for <linux-mm@kvack.org>; Mon, 09 Nov 2015 11:20:54 -0800 (PST)
Received: from g9t5008.houston.hp.com (g9t5008.houston.hp.com. [15.240.92.66])
        by mx.google.com with ESMTPS id v65si8883127ywb.320.2015.11.09.11.20.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Nov 2015 11:20:49 -0800 (PST)
Message-ID: <1447096601.21443.15.camel@hpe.com>
Subject: Re: [PATCH v4 RESEND 4/11] x86/asm: Fix pud/pmd interfaces to
 handle large PAT bit
From: Toshi Kani <toshi.kani@hpe.com>
Date: Mon, 09 Nov 2015 12:16:41 -0700
In-Reply-To: <5640E08F.5020206@oracle.com>
References: <1442514264-12475-1-git-send-email-toshi.kani@hpe.com>
	 <1442514264-12475-5-git-send-email-toshi.kani@hpe.com>
	 <5640E08F.5020206@oracle.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boris Ostrovsky <boris.ostrovsky@oracle.com>, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com
Cc: akpm@linux-foundation.org, bp@alien8.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, jgross@suse.com, konrad.wilk@oracle.com, elliott@hpe.com

On Mon, 2015-11-09 at 13:06 -0500, Boris Ostrovsky wrote:
> On 09/17/2015 02:24 PM, Toshi Kani wrote:
> > Now that we have pud/pmd mask interfaces, which handle pfn & flags
> > mask properly for the large PAT bit.
> > 
> > Fix pud/pmd pfn & flags interfaces by replacing PTE_PFN_MASK and
> > PTE_FLAGS_MASK with the pud/pmd mask interfaces.
> > 
> > Suggested-by: Juergen Gross <jgross@suse.com>
> > Signed-off-by: Toshi Kani <toshi.kani@hpe.com>
> > Cc: Juergen Gross <jgross@suse.com>
> > Cc: Konrad Wilk <konrad.wilk@oracle.com>
> > Cc: Thomas Gleixner <tglx@linutronix.de>
> > Cc: H. Peter Anvin <hpa@zytor.com>
> > Cc: Ingo Molnar <mingo@redhat.com>
> > Cc: Borislav Petkov <bp@alien8.de>
> > ---
> >   arch/x86/include/asm/pgtable.h       |   14 ++++++++------
> >   arch/x86/include/asm/pgtable_types.h |    4 ++--
> >   2 files changed, 10 insertions(+), 8 deletions(-)
> > 
> 
> 
> Looks like this commit is causing this splat for 32-bit kernels. I am 
> attaching my config file, just in case.

Thanks for the report!  I'd like to reproduce the issue since I am not sure how
this change caused it...

I tried to build a kernel with the attached config file, and got the following
error.  Not sure what I am missing.  

----
$ make -j24 ARCH=i386
   :
  LD      drivers/built-in.o
  LINK    vmlinux
./.config: line 44: $'\r': command not found
Makefile:929: recipe for target 'vmlinux' failed
make: *** [vmlinux] Error 127
----

Do you have steps to reproduce the issue?  Or do you see it during boot-time?

Thanks,
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

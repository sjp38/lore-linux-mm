Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 0D5606B0255
	for <linux-mm@kvack.org>; Mon, 25 Jan 2016 13:57:11 -0500 (EST)
Received: by mail-wm0-f42.google.com with SMTP id n5so95465733wmn.0
        for <linux-mm@kvack.org>; Mon, 25 Jan 2016 10:57:11 -0800 (PST)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id t187si106206wmg.54.2016.01.25.10.57.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Jan 2016 10:57:09 -0800 (PST)
Received: by mail-wm0-x244.google.com with SMTP id u188so13045173wmu.0
        for <linux-mm@kvack.org>; Mon, 25 Jan 2016 10:57:09 -0800 (PST)
Date: Mon, 25 Jan 2016 19:57:06 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH v2 0/3] x86/mm: INVPCID support
Message-ID: <20160125185706.GA28416@gmail.com>
References: <cover.1453746505.git.luto@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cover.1453746505.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>


* Andy Lutomirski <luto@kernel.org> wrote:

> Ingo, before applying this, please apply these two KASAN fixes:
> 
> http://lkml.kernel.org/g/1452516679-32040-2-git-send-email-aryabinin@virtuozzo.com
> http://lkml.kernel.org/g/1452516679-32040-3-git-send-email-aryabinin@virtuozzo.com
> 
> Without those fixes, this series will trigger a KASAN bug.
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
> This is exactly identical to patches 2-4 of the PCID RFC series.
> 
> Andy Lutomirski (3):
>   x86/mm: Add INVPCID helpers
>   x86/mm: Add a noinvpcid option to turn off INVPCID
>   x86/mm: If INVPCID is available, use it to flush global mappings
> 
>  Documentation/kernel-parameters.txt |  2 ++
>  arch/x86/include/asm/tlbflush.h     | 50 +++++++++++++++++++++++++++++++++++++
>  arch/x86/kernel/cpu/common.c        | 16 ++++++++++++
>  3 files changed, 68 insertions(+)

Ok, I'll pick these up tomorrow unless there are objections.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

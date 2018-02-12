Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id E4DDA6B0003
	for <linux-mm@kvack.org>; Mon, 12 Feb 2018 02:27:31 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id a6so1958511wme.9
        for <linux-mm@kvack.org>; Sun, 11 Feb 2018 23:27:31 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m189sor1117722wmd.62.2018.02.11.23.27.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 11 Feb 2018 23:27:30 -0800 (PST)
Date: Mon, 12 Feb 2018 08:27:27 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH] headers: untangle kmemleak.h from mm.h
Message-ID: <20180212072727.saupl35jvwex6hbe@gmail.com>
References: <a4629db7-194d-3c7c-c8fd-24f61b220a70@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a4629db7-194d-3c7c-c8fd-24f61b220a70@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@infradead.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>, iommu@lists.linux-foundation.org, linuxppc-dev@lists.ozlabs.org, linux-s390 <linux-s390@vger.kernel.org>, sparclinux@vger.kernel.org, X86 ML <x86@kernel.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, linux-wireless <linux-wireless@vger.kernel.org>, virtualization@lists.linux-foundation.org, John Johansen <john.johansen@canonical.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>


* Randy Dunlap <rdunlap@infradead.org> wrote:

> From: Randy Dunlap <rdunlap@infradead.org>
> 
> Currently <linux/slab.h> #includes <linux/kmemleak.h> for no obvious
> reason. It looks like it's only a convenience, so remove kmemleak.h
> from slab.h and add <linux/kmemleak.h> to any users of kmemleak_*
> that don't already #include it.
> Also remove <linux/kmemleak.h> from source files that do not use it.
> 
> This is tested on i386 allmodconfig and x86_64 allmodconfig. It
> would be good to run it through the 0day bot for other $ARCHes.
> I have neither the horsepower nor the storage space for the other
> $ARCHes.
> 
> [slab.h is the second most used header file after module.h; kernel.h
> is right there with slab.h. There could be some minor error in the
> counting due to some #includes having comments after them and I
> didn't combine all of those.]
> 
> This is Lingchi patch #1 (death by a thousand cuts, applied to kernel
> header files).
> 
> Signed-off-by: Randy Dunlap <rdunlap@infradead.org>

Nice find:

Reviewed-by: Ingo Molnar <mingo@kernel.org>

I agree that it needs to go through 0-day to find any hidden dependencies we might 
have grown due to this.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

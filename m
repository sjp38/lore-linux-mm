Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id DF2DA6B0038
	for <linux-mm@kvack.org>; Wed, 17 Aug 2016 15:18:10 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id 63so246127532pfx.0
        for <linux-mm@kvack.org>; Wed, 17 Aug 2016 12:18:10 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id xq3si494451pac.194.2016.08.17.12.18.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Aug 2016 12:18:10 -0700 (PDT)
Date: Wed, 17 Aug 2016 12:18:08 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [lkp] [mm]  122708b1b9: PANIC: early exception
Message-Id: <20160817121808.bf31e27382554bf532368c38@linux-foundation.org>
In-Reply-To: <20160817161028.GE20762@e104818-lin.cambridge.arm.com>
References: <1471360856-16916-1-git-send-email-catalin.marinas@arm.com>
	<20160817155141.GC3544@yexl-desktop>
	<20160817161028.GE20762@e104818-lin.cambridge.arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: kernel test robot <xiaolong.ye@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vignesh R <vigneshr@ti.com>, lkp@01.org

On Wed, 17 Aug 2016 17:10:28 +0100 Catalin Marinas <catalin.marinas@arm.com> wrote:

> On Wed, Aug 17, 2016 at 11:51:41PM +0800, kernel test robot wrote:
> > FYI, we noticed the following commit:
> > 
> > https://github.com/0day-ci/linux Catalin-Marinas/mm-kmemleak-Avoid-using-__va-on-addresses-that-don-t-have-a-lowmem-mapping/20160816-232733
> > commit 122708b1b91eb3d253baf86a263ead0f1f5cac78 ("mm: kmemleak: Avoid using __va() on addresses that don't have a lowmem mapping")
> > 
> > in testcase: boot
> > 
> > on test machine: 1 threads qemu-system-i386 -enable-kvm with 320M memory
> > 
> > caused below changes:
> > 
> > +--------------------------------+------------+------------+
> > |                                | 304bec1b1d | 122708b1b9 |
> > +--------------------------------+------------+------------+
> > | boot_successes                 | 3          | 0          |
> > | boot_failures                  | 5          | 8          |
> > | invoked_oom-killer:gfp_mask=0x | 1          |            |
> > | Mem-Info                       | 1          |            |
> > | BUG:kernel_test_crashed        | 4          |            |
> > | PANIC:early_exception          | 0          | 8          |
> > | EIP_is_at__phys_addr           | 0          | 8          |
> > | BUG:kernel_hang_in_boot_stage  | 0          | 2          |
> > | BUG:kernel_boot_hang           | 0          | 6          |
> > +--------------------------------+------------+------------+
> 
> Please disregard this patch. I posted v2 here:
> 
> http://lkml.kernel.org/g/1471426130-21330-1-git-send-email-catalin.marinas@arm.com
> 
> (and I'm eager to see the kbuild/kernel test robot results ;))

I don't see how the v1->v2 changes could fix a panic?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

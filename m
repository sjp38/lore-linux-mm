Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id D11C46B0038
	for <linux-mm@kvack.org>; Wed, 17 Aug 2016 12:10:33 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id o124so237826801pfg.1
        for <linux-mm@kvack.org>; Wed, 17 Aug 2016 09:10:33 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id y82si38311530pfd.118.2016.08.17.09.10.32
        for <linux-mm@kvack.org>;
        Wed, 17 Aug 2016 09:10:32 -0700 (PDT)
Date: Wed, 17 Aug 2016 17:10:28 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [lkp] [mm]  122708b1b9: PANIC: early exception
Message-ID: <20160817161028.GE20762@e104818-lin.cambridge.arm.com>
References: <1471360856-16916-1-git-send-email-catalin.marinas@arm.com>
 <20160817155141.GC3544@yexl-desktop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160817155141.GC3544@yexl-desktop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kernel test robot <xiaolong.ye@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vignesh R <vigneshr@ti.com>, lkp@01.org

On Wed, Aug 17, 2016 at 11:51:41PM +0800, kernel test robot wrote:
> FYI, we noticed the following commit:
> 
> https://github.com/0day-ci/linux Catalin-Marinas/mm-kmemleak-Avoid-using-__va-on-addresses-that-don-t-have-a-lowmem-mapping/20160816-232733
> commit 122708b1b91eb3d253baf86a263ead0f1f5cac78 ("mm: kmemleak: Avoid using __va() on addresses that don't have a lowmem mapping")
> 
> in testcase: boot
> 
> on test machine: 1 threads qemu-system-i386 -enable-kvm with 320M memory
> 
> caused below changes:
> 
> +--------------------------------+------------+------------+
> |                                | 304bec1b1d | 122708b1b9 |
> +--------------------------------+------------+------------+
> | boot_successes                 | 3          | 0          |
> | boot_failures                  | 5          | 8          |
> | invoked_oom-killer:gfp_mask=0x | 1          |            |
> | Mem-Info                       | 1          |            |
> | BUG:kernel_test_crashed        | 4          |            |
> | PANIC:early_exception          | 0          | 8          |
> | EIP_is_at__phys_addr           | 0          | 8          |
> | BUG:kernel_hang_in_boot_stage  | 0          | 2          |
> | BUG:kernel_boot_hang           | 0          | 6          |
> +--------------------------------+------------+------------+

Please disregard this patch. I posted v2 here:

http://lkml.kernel.org/g/1471426130-21330-1-git-send-email-catalin.marinas@arm.com

(and I'm eager to see the kbuild/kernel test robot results ;))

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 153276B02C4
	for <linux-mm@kvack.org>; Mon, 15 May 2017 15:48:06 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id c2so109331441pfd.9
        for <linux-mm@kvack.org>; Mon, 15 May 2017 12:48:06 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id w20si11531978pgj.290.2017.05.15.12.48.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 May 2017 12:48:05 -0700 (PDT)
Date: Mon, 15 May 2017 22:48:00 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCHv5, REBASED 9/9] x86/mm: Allow to have userspace mappings
 above 47-bits
Message-ID: <20170515194759.di5pojt46e2lxo2p@black.fi.intel.com>
References: <20170515121218.27610-10-kirill.shutemov@linux.intel.com>
 <201705152204.F4FmHH4W%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201705152204.F4FmHH4W%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, Dan Williams <dan.j.williams@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org

On Mon, May 15, 2017 at 10:49:43PM +0800, kbuild test robot wrote:
> Hi Kirill,
> 
> [auto build test ERROR on linus/master]
> [also build test ERROR on v4.12-rc1 next-20170515]
> [cannot apply to tip/x86/core xen-tip/linux-next]
> [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
> 
> url:    https://github.com/0day-ci/linux/commits/Kirill-A-Shutemov/x86-5-level-paging-enabling-for-v4-12-Part-4/20170515-202736
> config: i386-defconfig (attached as .config)
> compiler: gcc-6 (Debian 6.2.0-3) 6.2.0 20160901
> reproduce:
>         # save the attached .config to linux build tree
>         make ARCH=i386 
> 
> All error/warnings (new ones prefixed by >>):
> 
>    In file included from include/linux/cache.h:4:0,
>                     from include/linux/printk.h:8,
>                     from include/linux/kernel.h:13,
>                     from mm/mmap.c:11:
>    mm/mmap.c: In function 'arch_get_unmapped_area_topdown':
>    arch/x86/include/asm/processor.h:878:50: error: 'TASK_SIZE_LOW' undeclared (first use in this function)
>     #define TASK_UNMAPPED_BASE  __TASK_UNMAPPED_BASE(TASK_SIZE_LOW)

Thanks. Fixup is below.

Let me know if I need to send the full patch:

diff --git a/arch/x86/include/asm/processor.h b/arch/x86/include/asm/processor.h
index aaed58b03ddb..65663de9287b 100644
--- a/arch/x86/include/asm/processor.h
+++ b/arch/x86/include/asm/processor.h
@@ -794,6 +794,7 @@ static inline void spin_lock_prefetch(const void *x)
  */
 #define IA32_PAGE_OFFSET	PAGE_OFFSET
 #define TASK_SIZE		PAGE_OFFSET
+#define TASK_SIZE_LOW		TASK_SIZE
 #define TASK_SIZE_MAX		TASK_SIZE
 #define DEFAULT_MAP_WINDOW	TASK_SIZE
 #define STACK_TOP		TASK_SIZE
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

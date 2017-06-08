Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4620D6B0279
	for <linux-mm@kvack.org>; Thu,  8 Jun 2017 03:40:00 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id q78so7254196pfj.9
        for <linux-mm@kvack.org>; Thu, 08 Jun 2017 00:40:00 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id 4si3670368pla.142.2017.06.08.00.39.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Jun 2017 00:39:59 -0700 (PDT)
Date: Thu, 8 Jun 2017 15:39:03 +0800
From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH v6 10/34] x86, x86/mm, x86/xen, olpc: Use __va() against
 just the physical address in cr3
Message-ID: <201706081509.rlvRTFuv%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="T4sUOijqQbZv57TR"
Content-Disposition: inline
In-Reply-To: <20170607191453.28645.92256.stgit@tlendack-t1.amdoffice.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: kbuild-all@01.org, linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S. Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dave Young <dyoung@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>


--T4sUOijqQbZv57TR
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Tom,

[auto build test ERROR on linus/master]
[also build test ERROR on v4.12-rc4 next-20170607]
[cannot apply to tip/x86/core]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/Tom-Lendacky/x86-Secure-Memory-Encryption-AMD/20170608-104147
config: um-x86_64_defconfig (attached as .config)
compiler: gcc-6 (Debian 6.2.0-3) 6.2.0 20160901
reproduce:
        # save the attached .config to linux build tree
        make ARCH=um SUBARCH=x86_64

All errors (new ones prefixed by >>):

   In file included from arch/x86/include/asm/cacheflush.h:6:0,
                    from include/linux/highmem.h:11,
                    from net/core/sock.c:116:
   arch/x86/include/asm/special_insns.h: In function 'native_read_cr3_pa':
>> arch/x86/include/asm/special_insns.h:239:30: error: 'PHYSICAL_PAGE_MASK' undeclared (first use in this function)
     return (native_read_cr3() & PHYSICAL_PAGE_MASK);
                                 ^~~~~~~~~~~~~~~~~~
   arch/x86/include/asm/special_insns.h:239:30: note: each undeclared identifier is reported only once for each function it appears in
   arch/x86/include/asm/special_insns.h: In function 'read_cr3_pa':
   arch/x86/include/asm/special_insns.h:244:23: error: 'PHYSICAL_PAGE_MASK' undeclared (first use in this function)
     return (read_cr3() & PHYSICAL_PAGE_MASK);
                          ^~~~~~~~~~~~~~~~~~

vim +/PHYSICAL_PAGE_MASK +239 arch/x86/include/asm/special_insns.h

   233	}
   234	
   235	#define nop() asm volatile ("nop")
   236	
   237	static inline unsigned long native_read_cr3_pa(void)
   238	{
 > 239		return (native_read_cr3() & PHYSICAL_PAGE_MASK);
   240	}
   241	
   242	static inline unsigned long read_cr3_pa(void)

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--T4sUOijqQbZv57TR
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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

--T4sUOijqQbZv57TR--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

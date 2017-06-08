Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8FE186B0343
	for <linux-mm@kvack.org>; Thu,  8 Jun 2017 17:09:50 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id l22so18366763pfb.11
        for <linux-mm@kvack.org>; Thu, 08 Jun 2017 14:09:50 -0700 (PDT)
Received: from NAM03-BY2-obe.outbound.protection.outlook.com (mail-by2nam03on0049.outbound.protection.outlook.com. [104.47.42.49])
        by mx.google.com with ESMTPS id y8si5227163pgr.175.2017.06.08.14.09.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 08 Jun 2017 14:09:49 -0700 (PDT)
Subject: Re: [PATCH v6 25/34] swiotlb: Add warnings for use of bounce buffers
 with SME
References: <201706081348.u0hG73ce%fengguang.wu@intel.com>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <56d5d7bf-45f9-6d66-d71a-166ecb60296c@amd.com>
Date: Thu, 8 Jun 2017 16:09:36 -0500
MIME-Version: 1.0
In-Reply-To: <201706081348.u0hG73ce%fengguang.wu@intel.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org, linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S. Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dave Young <dyoung@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On 6/8/2017 12:53 AM, kbuild test robot wrote:
> Hi Tom,
> 
> [auto build test ERROR on linus/master]
> [also build test ERROR on v4.12-rc4 next-20170607]
> [cannot apply to tip/x86/core]
> [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
> 
> url:    https://github.com/0day-ci/linux/commits/Tom-Lendacky/x86-Secure-Memory-Encryption-AMD/20170608-104147
> config: sparc-defconfig (attached as .config)
> compiler: sparc-linux-gcc (GCC) 6.2.0
> reproduce:
>          wget https://raw.githubusercontent.com/01org/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
>          chmod +x ~/bin/make.cross
>          # save the attached .config to linux build tree
>          make.cross ARCH=sparc
> 
> All errors (new ones prefixed by >>):
> 
>     In file included from include/linux/dma-mapping.h:13:0,
>                      from include/linux/skbuff.h:34,
>                      from include/linux/filter.h:12,
>                      from kernel//bpf/core.c:24:
>>> include/linux/mem_encrypt.h:16:29: fatal error: asm/mem_encrypt.h: No such file or directory
>      #include <asm/mem_encrypt.h>
>                                  ^
>     compilation terminated.

Okay, I had the wrong understanding of the asm-generic directory. The
next series will fix this so it is not an issue for other arches.

Thanks,
Tom

> 
> vim +16 include/linux/mem_encrypt.h
> 
> 2d7c2ec4 Tom Lendacky 2017-06-07  10   * published by the Free Software Foundation.
> 2d7c2ec4 Tom Lendacky 2017-06-07  11   */
> 2d7c2ec4 Tom Lendacky 2017-06-07  12
> 2d7c2ec4 Tom Lendacky 2017-06-07  13  #ifndef __MEM_ENCRYPT_H__
> 2d7c2ec4 Tom Lendacky 2017-06-07  14  #define __MEM_ENCRYPT_H__
> 2d7c2ec4 Tom Lendacky 2017-06-07  15
> 2d7c2ec4 Tom Lendacky 2017-06-07 @16  #include <asm/mem_encrypt.h>
> 2d7c2ec4 Tom Lendacky 2017-06-07  17
> 2d7c2ec4 Tom Lendacky 2017-06-07  18  #endif	/* __MEM_ENCRYPT_H__ */
> 
> :::::: The code at line 16 was first introduced by commit
> :::::: 2d7c2ec4c60e83432b27bfb32042706f404d4158 x86/mm: Add Secure Memory Encryption (SME) support
> 
> :::::: TO: Tom Lendacky <thomas.lendacky@amd.com>
> :::::: CC: 0day robot <fengguang.wu@intel.com>
> 
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

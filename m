Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id E9F756B000C
	for <linux-mm@kvack.org>; Sat, 10 Feb 2018 20:29:14 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id 73so6842949wrb.13
        for <linux-mm@kvack.org>; Sat, 10 Feb 2018 17:29:14 -0800 (PST)
Received: from huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id i33si2026263edi.437.2018.02.10.17.29.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 10 Feb 2018 17:29:12 -0800 (PST)
Subject: Re: [PATCH 5/6] Pmalloc: self-test
References: <20180204170056.28772-1-igor.stoppa@huawei.com>
 <201802080158.oKwP7HVR%fengguang.wu@intel.com>
From: Igor Stoppa <igor.stoppa@huawei.com>
Message-ID: <655ac34e-cca7-f619-6d67-348fa596297c@huawei.com>
Date: Sun, 11 Feb 2018 03:28:53 +0200
MIME-Version: 1.0
In-Reply-To: <201802080158.oKwP7HVR%fengguang.wu@intel.com>
Content-Type: text/plain; charset="windows-1252"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org, jglisse@redhat.com, keescook@chromium.org, mhocko@kernel.org, labbott@redhat.com, hch@infradead.org, willy@infradead.org, cl@linux.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com



On 07/02/18 19:18, kbuild test robot wrote:
> Hi Igor,
> 
> Thank you for the patch! Yet something to improve:
> 
> [auto build test ERROR on kees/for-next/pstore]
> [also build test ERROR on v4.15]
> [cannot apply to linus/master mmotm/master next-20180207]
> [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
> 
> url:    https://github.com/0day-ci/linux/commits/Igor-Stoppa/mm-security-ro-protection-for-dynamic-data/20180207-171252
> base:   https://git.kernel.org/pub/scm/linux/kernel/git/kees/linux.git for-next/pstore
> config: i386-randconfig-s1-201805+bisect_validate (attached as .config)
> compiler: gcc-6 (Debian 6.4.0-9) 6.4.0 20171026
> reproduce:
>         # save the attached .config to linux build tree
>         make ARCH=i386 
> 
> All errors (new ones prefixed by >>):
> 
>    mm/pmalloc.o: In function `pmalloc_pool_show_chunks':
>>> mm/pmalloc.c:100: undefined reference to `gen_pool_for_each_chunk'
>    mm/pmalloc.o: In function `pmalloc_pool_show_size':
>>> mm/pmalloc.c:81: undefined reference to `gen_pool_size'
>    mm/pmalloc.o: In function `pmalloc_pool_show_avail':
>>> mm/pmalloc.c:70: undefined reference to `gen_pool_avail'
>    mm/pmalloc.o: In function `pmalloc_chunk_free':
>>> mm/pmalloc.c:459: undefined reference to `gen_pool_flush_chunk'
>    mm/pmalloc.o: In function `pmalloc_create_pool':
>>> mm/pmalloc.c:173: undefined reference to `gen_pool_create'
>>> mm/pmalloc.c:210: undefined reference to `gen_pool_destroy'
>    mm/pmalloc.o: In function `gen_pool_add':
>>> include/linux/genalloc.h:115: undefined reference to `gen_pool_add_virt'
>    mm/pmalloc.o: In function `pmalloc':
>>> mm/pmalloc.c:357: undefined reference to `gen_pool_alloc'
>    mm/pmalloc.o: In function `gen_pool_add':
>>> include/linux/genalloc.h:115: undefined reference to `gen_pool_add_virt'
>    mm/pmalloc.o: In function `pmalloc':
>    mm/pmalloc.c:386: undefined reference to `gen_pool_alloc'
>    mm/pmalloc.o: In function `pmalloc_destroy_pool':
>    mm/pmalloc.c:484: undefined reference to `gen_pool_for_each_chunk'
>    mm/pmalloc.c:485: undefined reference to `gen_pool_destroy'

Wrong default value for the pmalloc Kconfig option, it must default to
true. Will fix it.

--
igor

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

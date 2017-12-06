Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 08CA36B026D
	for <linux-mm@kvack.org>; Tue,  5 Dec 2017 19:09:33 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id o16so1031626wmf.4
        for <linux-mm@kvack.org>; Tue, 05 Dec 2017 16:09:32 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 124si1021234wmf.110.2017.12.05.16.09.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Dec 2017 16:09:31 -0800 (PST)
Date: Tue, 5 Dec 2017 16:09:28 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [linux-next:master 2148/2944] lib/find_bit_benchmark.c:115:7:
 error: implicit declaration of function 'find_next_and_bit'; did you mean
 'find_next_bit'?
Message-Id: <20171205160928.8eef0f54c63cb05d67c5c7b9@linux-foundation.org>
In-Reply-To: <201712052024.0kVygoFI%fengguang.wu@intel.com>
References: <201712052024.0kVygoFI%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: Clement Courbet <courbet@google.com>, kbuild-all@01.org, Linux Memory Management List <linux-mm@kvack.org>, Geert Uytterhoeven <geert@linux-m68k.org>

On Tue, 5 Dec 2017 20:31:28 +0800 kbuild test robot <fengguang.wu@intel.com> wrote:

> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
> head:   7ceb97a071e80f1b5e4cd5a36de135612a836388
> commit: e49c614e6b37254b1e7bf55c631ce3cb5e3b6433 [2148/2944] lib: optimize cpumask_next_and()
> config: m68k-allmodconfig (attached as .config)
> compiler: m68k-linux-gnu-gcc (Debian 7.2.0-11) 7.2.0
> reproduce:
>         wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         git checkout e49c614e6b37254b1e7bf55c631ce3cb5e3b6433
>         # save the attached .config to linux build tree
>         make.cross ARCH=m68k 
> 
> All errors (new ones prefixed by >>):
> 
>    lib/find_bit_benchmark.c: In function 'test_find_next_and_bit':
> >> lib/find_bit_benchmark.c:115:7: error: implicit declaration of function 'find_next_and_bit'; did you mean 'find_next_bit'? [-Werror=implicit-function-declaration]
>       i = find_next_and_bit(bitmap, bitmap2, BITMAP_LEN, i+1);
>           ^~~~~~~~~~~~~~~~~
>           find_next_bit
>    cc1: some warnings being treated as errors

For some reason m68k doesn't include asm-generic/bitops/find.h from
arch/m68k/include/asm/bitops.h.  One for Clement and Geert to puzzle
out, please.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

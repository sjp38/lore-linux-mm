Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 86FC66B0369
	for <linux-mm@kvack.org>; Wed,  6 Dec 2017 03:42:09 -0500 (EST)
Received: by mail-qt0-f200.google.com with SMTP id e2so2666408qti.3
        for <linux-mm@kvack.org>; Wed, 06 Dec 2017 00:42:09 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g98sor1372766qkh.152.2017.12.06.00.42.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 06 Dec 2017 00:42:08 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171205160928.8eef0f54c63cb05d67c5c7b9@linux-foundation.org>
References: <201712052024.0kVygoFI%fengguang.wu@intel.com> <20171205160928.8eef0f54c63cb05d67c5c7b9@linux-foundation.org>
From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Wed, 6 Dec 2017 09:42:07 +0100
Message-ID: <CAMuHMdW4W5T_KX-bm4zD=yOOnHBRn9BiTNg3DN=+izjknVo4uQ@mail.gmail.com>
Subject: Re: [linux-next:master 2148/2944] lib/find_bit_benchmark.c:115:7:
 error: implicit declaration of function 'find_next_and_bit'; did you mean 'find_next_bit'?
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kbuild test robot <fengguang.wu@intel.com>, Clement Courbet <courbet@google.com>, "kbuild-all@01.org" <kbuild-all@01.org>, Linux Memory Management List <linux-mm@kvack.org>

Hi Andrew,

On Wed, Dec 6, 2017 at 1:09 AM, Andrew Morton <akpm@linux-foundation.org> wrote:
> On Tue, 5 Dec 2017 20:31:28 +0800 kbuild test robot <fengguang.wu@intel.com> wrote:
>> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
>> head:   7ceb97a071e80f1b5e4cd5a36de135612a836388
>> commit: e49c614e6b37254b1e7bf55c631ce3cb5e3b6433 [2148/2944] lib: optimize cpumask_next_and()
>> config: m68k-allmodconfig (attached as .config)
>> compiler: m68k-linux-gnu-gcc (Debian 7.2.0-11) 7.2.0
>> reproduce:
>>         wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
>>         chmod +x ~/bin/make.cross
>>         git checkout e49c614e6b37254b1e7bf55c631ce3cb5e3b6433
>>         # save the attached .config to linux build tree
>>         make.cross ARCH=m68k
>>
>> All errors (new ones prefixed by >>):
>>
>>    lib/find_bit_benchmark.c: In function 'test_find_next_and_bit':
>> >> lib/find_bit_benchmark.c:115:7: error: implicit declaration of function 'find_next_and_bit'; did you mean 'find_next_bit'? [-Werror=implicit-function-declaration]
>>       i = find_next_and_bit(bitmap, bitmap2, BITMAP_LEN, i+1);
>>           ^~~~~~~~~~~~~~~~~
>>           find_next_bit
>>    cc1: some warnings being treated as errors
>
> For some reason m68k doesn't include asm-generic/bitops/find.h from
> arch/m68k/include/asm/bitops.h.  One for Clement and Geert to puzzle
> out, please.

Oh it does, but only for the CONFIG_CPU_HAS_NO_BITFIELDS=y case.
Which used to be fine, as the code for CONFIG_CPU_HAS_NO_BITFIELDS=n
implemented everything in find.h, until find_next_and_bit() was added.

Thanks, will fix...

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f43.google.com (mail-qg0-f43.google.com [209.85.192.43])
	by kanga.kvack.org (Postfix) with ESMTP id 1AE846B0038
	for <linux-mm@kvack.org>; Thu, 17 Sep 2015 14:34:25 -0400 (EDT)
Received: by qgt47 with SMTP id 47so20225405qgt.2
        for <linux-mm@kvack.org>; Thu, 17 Sep 2015 11:34:25 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id v23si3866135qkv.126.2015.09.17.11.34.24
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Sep 2015 11:34:24 -0700 (PDT)
Date: Thu, 17 Sep 2015 11:34:22 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [linux-next:master 2171/2223] lib/test-string_helpers.c:336:32:
 note: in expansion of macro 'min'
Message-Id: <20150917113422.1d67ee7d09bbd87900b9dc29@linux-foundation.org>
In-Reply-To: <201509171413.HY8sjcvk%fengguang.wu@intel.com>
References: <201509171413.HY8sjcvk%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: Vitaly Kuznetsov <vkuznets@redhat.com>, kbuild-all@01.org, Linux Memory Management List <linux-mm@kvack.org>

On Thu, 17 Sep 2015 14:33:15 +0800 kbuild test robot <fengguang.wu@intel.com> wrote:

> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
> head:   01c8787d7f7ea56c16d94cf7133022189be231ad
> commit: 42c38b1726a7df8aee87c44e5151b0f29ab5ab3b [2171/2223] lib/test-string_helpers.c: add string_get_size() tests
> config: mn10300-allyesconfig (attached as .config)
> reproduce:
>   wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
>   chmod +x ~/bin/make.cross
>   git checkout 42c38b1726a7df8aee87c44e5151b0f29ab5ab3b
>   # save the attached .config to linux build tree
>   make.cross ARCH=mn10300 
> 
> All warnings (new ones prefixed by >>):
> 
>    In file included from lib/test-string_helpers.c:7:0:
>    lib/test-string_helpers.c: In function 'test_string_get_size_one':
>    include/linux/kernel.h:722:17: warning: comparison of distinct pointer types lacks a cast
>      (void) (&_min1 == &_min2);  \
>                     ^
> >> lib/test-string_helpers.c:336:32: note: in expansion of macro 'min'
>      if (!strncmp(buf, exp_result, min(sizeof(buf), strlen(exp_result))))
>                                    ^
> 
> ...
>
>  > 336		if (!strncmp(buf, exp_result, min(sizeof(buf), strlen(exp_result))))

It looks like mn10300 gcc is busted.  sizeof and strlen() both return
size_t.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

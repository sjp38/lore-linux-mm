Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f180.google.com (mail-pf0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id C517F6B0256
	for <linux-mm@kvack.org>; Thu, 10 Dec 2015 11:01:35 -0500 (EST)
Received: by pfnn128 with SMTP id n128so50064485pfn.0
        for <linux-mm@kvack.org>; Thu, 10 Dec 2015 08:01:35 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id rm10si21082333pab.25.2015.12.10.08.01.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Dec 2015 08:01:35 -0800 (PST)
Subject: Re: [linux-next:master 5266/5426]
 arch/x86/kernel/cpu/mcheck/mce.c:884:5: warning: 'order' may be used
 uninitialized in this function
References: <201512102333.nZemw8i3%fengguang.wu@intel.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <5669A205.7080205@virtuozzo.com>
Date: Thu, 10 Dec 2015 19:02:13 +0300
MIME-Version: 1.0
In-Reply-To: <201512102333.nZemw8i3%fengguang.wu@intel.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>



On 12/10/2015 06:05 PM, kbuild test robot wrote:
> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
> head:   8225f4e85cb03daea14661380745886ce01fd83a
> commit: 0dd08f12cafd7868be55bc10ebcd4ea13880860b [5266/5426] UBSAN: run-time undefined behavior sanity checker
> config: x86_64-randconfig-s5-12102221 (attached as .config)
> reproduce:
>         git checkout 0dd08f12cafd7868be55bc10ebcd4ea13880860b
>         # save the attached .config to linux build tree
>         make ARCH=x86_64 
> 
> Note: it may well be a FALSE warning. FWIW you are at least aware of it now.
> http://gcc.gnu.org/wiki/Better_Uninitialized_Warnings
> 

This is certainly a false positive. 
It seems that UBSAN could make gcc more stupid and increase number of maybe-uninitialized false-positives.


> All warnings (new ones prefixed by >>):
> 
>    arch/x86/kernel/cpu/mcheck/mce.c: In function 'do_machine_check':
>>> arch/x86/kernel/cpu/mcheck/mce.c:884:5: warning: 'order' may be used uninitialized in this function [-Wmaybe-uninitialized]
>      if (order == 1) {
>         ^
>    arch/x86/kernel/cpu/mcheck/mce.c:984:6: note: 'order' was declared here
>      int order;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

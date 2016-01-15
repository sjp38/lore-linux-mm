Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f180.google.com (mail-lb0-f180.google.com [209.85.217.180])
	by kanga.kvack.org (Postfix) with ESMTP id 39310828DF
	for <linux-mm@kvack.org>; Fri, 15 Jan 2016 11:16:34 -0500 (EST)
Received: by mail-lb0-f180.google.com with SMTP id x4so61019841lbm.0
        for <linux-mm@kvack.org>; Fri, 15 Jan 2016 08:16:34 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id ot1si6046814lbb.79.2016.01.15.08.16.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Jan 2016 08:16:32 -0800 (PST)
Subject: Re: [linux-next:master 11446/11650]
 drivers/pwm/pwm-atmel-hlcdc.c:75:55: warning: 'clk_period_ns' may be used
 uninitialized in this function
References: <201601151603.wGuE709l%fengguang.wu@intel.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <56991B91.1050105@virtuozzo.com>
Date: Fri, 15 Jan 2016 19:17:21 +0300
MIME-Version: 1.0
In-Reply-To: <201601151603.wGuE709l%fengguang.wu@intel.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

On 01/15/2016 11:56 AM, kbuild test robot wrote:
> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
> head:   39750fe2d360d6f1ccdc6b33d0a5cb624c97a5fd
> commit: df423af30988b62df3905601742b8948bbbce329 [11446/11650] UBSAN: run-time undefined behavior sanity checker
> config: x86_64-randconfig-s5-01151613 (attached as .config)
> reproduce:
>         git checkout df423af30988b62df3905601742b8948bbbce329
>         # save the attached .config to linux build tree
>         make ARCH=x86_64 
> 
> Note: it may well be a FALSE warning. FWIW you are at least aware of it now.
> http://gcc.gnu.org/wiki/Better_Uninitialized_Warnings
> 

Hmm.. UBSAN (and KASAN too) causes some maybe-uninitialized false positives.
I'm not in favor of mucking different subsystems and initializing these variables as it brings some runtime overhead.
So, perhaps we need turn off UBSAN/KASAN in all[yes|mod]config builds plus build with -Wno-maybe-uninitilized if any of those options enabled.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

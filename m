Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 444B44405A1
	for <linux-mm@kvack.org>; Wed, 15 Feb 2017 04:38:07 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id e137so63402463itc.0
        for <linux-mm@kvack.org>; Wed, 15 Feb 2017 01:38:07 -0800 (PST)
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-db5eur01on0114.outbound.protection.outlook.com. [104.47.2.114])
        by mx.google.com with ESMTPS id b1si3526064iog.75.2017.02.15.01.38.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 15 Feb 2017 01:38:06 -0800 (PST)
Subject: Re: [PATCHv5 1/5] x86/mm: introduce arch_rnd() to compute 32/64 mmap
 rnd
References: <201702150640.DEwJ0Wro%fengguang.wu@intel.com>
From: Dmitry Safonov <dsafonov@virtuozzo.com>
Message-ID: <9dbe048c-b332-199d-3d80-dad0562e3153@virtuozzo.com>
Date: Wed, 15 Feb 2017 12:34:19 +0300
MIME-Version: 1.0
In-Reply-To: <201702150640.DEwJ0Wro%fengguang.wu@intel.com>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org, linux-kernel@vger.kernel.org, 0x7f454c46@gmail.com, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@suse.de>, x86@kernel.org, linux-mm@kvack.org, Cyrill Gorcunov <gorcunov@openvz.org>

On 02/15/2017 01:22 AM, kbuild test robot wrote:
> Hi Dmitry,
...
> vim +/mmap_rnd_compat_bits +58 arch/x86/mm/mmap.c
>
>     52	 * Leave an at least ~128 MB hole with possible stack randomization.
>     53	 */
>     54	#define MIN_GAP (128*1024*1024UL + stack_maxrandom_size())
>     55	#define MAX_GAP (TASK_SIZE/6*5)
>     56	
>     57	#ifdef CONFIG_64BIT
>   > 58	# define mmap32_rnd_bits  mmap_rnd_compat_bits
>     59	# define mmap64_rnd_bits  mmap_rnd_bits
>     60	#else
>     61	# define mmap32_rnd_bits  mmap_rnd_bits
>     62	# define mmap64_rnd_bits  mmap_rnd_bits
>     63	#endif

Yep, thanks - it's better be ifdef CONFIG_COMPAT.
Will resend today with this trivial fixup.

-- 
              Dmitry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 0D0FF6B0254
	for <linux-mm@kvack.org>; Wed, 10 Feb 2016 14:56:12 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id ho8so16757346pac.2
        for <linux-mm@kvack.org>; Wed, 10 Feb 2016 11:56:12 -0800 (PST)
Received: from mail.zytor.com (terminus.zytor.com. [2001:1868:205::10])
        by mx.google.com with ESMTPS id ut10si6970115pab.139.2016.02.10.11.56.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Feb 2016 11:56:11 -0800 (PST)
Subject: Re: undefined reference to `efi_call'
References: <201602101626.jtqGm2RN%fengguang.wu@intel.com>
 <20160210115234.234e2bab71db2028c98b58ad@linux-foundation.org>
From: "H. Peter Anvin" <hpa@zytor.com>
Message-ID: <56BB95C3.8010003@zytor.com>
Date: Wed, 10 Feb 2016 11:55:47 -0800
MIME-Version: 1.0
In-Reply-To: <20160210115234.234e2bab71db2028c98b58ad@linux-foundation.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, kbuild test robot <fengguang.wu@intel.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, kbuild-all@01.org, linux-kernel@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Linux Memory Management List <linux-mm@kvack.org>, Matt Fleming <matt@codeblueprint.co.uk>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>

On 02/10/16 11:52, Andrew Morton wrote:
> On Wed, 10 Feb 2016 16:48:28 +0800 kbuild test robot <fengguang.wu@intel.com> wrote:
> 
>> Hi Johannes,
>>
>> It's probably a bug fix that unveils the link errors.
>>
>> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master
>> head:   2178cbc68f3602dc0b5949b9be2c8383ad3d93ef
>> commit: 489c2a20a414351fe0813a727c34600c0f7292ae mm: memcontrol: introduce CONFIG_MEMCG_LEGACY_KMEM
>> date:   3 weeks ago
>> config: x86_64-randconfig-s3-02101458 (attached as .config)
>> reproduce:
>>         git checkout 489c2a20a414351fe0813a727c34600c0f7292ae
>>         # save the attached .config to linux build tree
>>         make ARCH=x86_64 
>>
>> All errors (new ones prefixed by >>):
>>
>>    arch/x86/built-in.o: In function `uv_bios_call':
>>>> (.text+0xeba00): undefined reference to `efi_call'
> 
> I'd be surprised if the above patch caused this.
> 
> CONFIG_EFI=n
> 
> CONFIG_X86_UV does not depend on EFI.
> 
X86_UV ought to depend on EFI.

	-hpa

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

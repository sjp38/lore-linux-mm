Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5E78B6B0003
	for <linux-mm@kvack.org>; Wed, 21 Feb 2018 12:53:47 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id h14so2051868wre.19
        for <linux-mm@kvack.org>; Wed, 21 Feb 2018 09:53:47 -0800 (PST)
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id m20si12692395wrb.65.2018.02.21.09.53.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Feb 2018 09:53:45 -0800 (PST)
Subject: Re: [PATCH 5/6] powerpc: Implement DISCONTIGMEM and allow selection
 on PPC32
References: <20180220161424.5421-6-j.neuschaefer@gmx.net>
 <201802210756.OZokd64C%fengguang.wu@intel.com>
 <20180221160815.dxhpsejt74zeqqjd@latitude>
From: christophe leroy <christophe.leroy@c-s.fr>
Message-ID: <a0c7806e-e06e-eb6c-416b-022bdc36d757@c-s.fr>
Date: Wed, 21 Feb 2018 18:53:43 +0100
MIME-Version: 1.0
In-Reply-To: <20180221160815.dxhpsejt74zeqqjd@latitude>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Language: fr
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?Q?Jonathan_Neusch=c3=a4fer?= <j.neuschaefer@gmx.net>
Cc: Kate Stewart <kstewart@linuxfoundation.org>, Kees Cook <keescook@chromium.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Philippe Ombredanne <pombredanne@nexb.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Bringmann <mwb@linux.vnet.ibm.com>, Paul Mackerras <paulus@samba.org>, kbuild-all@01.org, Thiago Jung Bauermann <bauerman@linux.vnet.ibm.com>, Nathan Fontenot <nfont@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, linuxppc-dev@lists.ozlabs.org, Joel Stanley <joel@jms.id.au>



Le 21/02/2018 a 17:08, Jonathan Neuschafer a ecrit :
> On Wed, Feb 21, 2018 at 07:46:28AM +0800, kbuild test robot wrote:
> [...]
>>>> include/linux/mmzone.h:1239:19: error: conflicting types for 'pfn_valid'
>>      static inline int pfn_valid(unsigned long pfn)
>>                        ^~~~~~~~~
>>     In file included from include/linux/mmzone.h:912:0,
>>                      from include/linux/gfp.h:6,
>>                      from include/linux/mm.h:10,
>>                      from include/linux/mman.h:5,
>>                      from arch/powerpc/kernel/asm-offsets.c:22:
>>     arch/powerpc/include/asm/mmzone.h:40:19: note: previous definition of 'pfn_valid' was here
>>      static inline int pfn_valid(int pfn)
>>                        ^~~~~~~~~
>>     make[2]: *** [arch/powerpc/kernel/asm-offsets.s] Error 1
>>     make[2]: Target '__build' not remade because of errors.
>>     make[1]: *** [prepare0] Error 2
>>     make[1]: Target 'prepare' not remade because of errors.
>>     make: *** [sub-make] Error 2
> 
> Oops, I'll fix this in the next version (and compile-test on ppc64...).
> 
> Weirdly enough, x86-32 and parisc define pfn_valid with an int
> parameter, too (both of them since the Beginning Of Time, aka.
> v2.6.12-rc2).
> 

Behind the fact that the pfn type is different, my understanding is that 
you have to define CONFIG_HAVE_ARCH_PFN_VALID in the Kconfig in order to 
avoid it being included in include/linux/mmzone.h

Christophe

---
L'absence de virus dans ce courrier electronique a ete verifiee par le logiciel antivirus Avast.
https://www.avast.com/antivirus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id C92EC6B0292
	for <linux-mm@kvack.org>; Fri,  1 Sep 2017 01:11:20 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id 62so168244iok.7
        for <linux-mm@kvack.org>; Thu, 31 Aug 2017 22:11:20 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id 40si1253299iol.386.2017.08.31.22.11.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Aug 2017 22:11:19 -0700 (PDT)
Subject: Re: mmotm 2017-08-31-16-13 uploaded (x86/kernel/eisa.c)
References: <59a8982c.FwLJY62HB+esikOu%akpm@linux-foundation.org>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <43a5f1af-2135-191e-4640-9f9cc50b34ca@infradead.org>
Date: Thu, 31 Aug 2017 22:11:11 -0700
MIME-Version: 1.0
In-Reply-To: <59a8982c.FwLJY62HB+esikOu%akpm@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, X86 ML <x86@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, mhocko@suse.cz, broonie@kernel.org

On 08/31/17 16:13, akpm@linux-foundation.org wrote:
> The mm-of-the-moment snapshot 2017-08-31-16-13 has been uploaded to
> 
>    http://www.ozlabs.org/~akpm/mmotm/
> 
> mmotm-readme.txt says
> 
> README for mm-of-the-moment:
> 
> http://www.ozlabs.org/~akpm/mmotm/
> 
> This is a snapshot of my -mm patch queue.  Uploaded at random hopefully
> more than once a week.


from linux-next.patch:

on i386:

  CC      arch/x86/kernel/eisa.o
../arch/x86/kernel/eisa.c: In function 'eisa_bus_probe':
../arch/x86/kernel/eisa.c:11:2: error: implicit declaration of function 'ioremap' [-Werror=implicit-function-declaration]
  void __iomem *p = ioremap(0x0FFFD9, 4);
  ^
../arch/x86/kernel/eisa.c:11:20: warning: initialization makes pointer from integer without a cast [enabled by default]
  void __iomem *p = ioremap(0x0FFFD9, 4);
                    ^
../arch/x86/kernel/eisa.c:13:2: error: implicit declaration of function 'readl' [-Werror=implicit-function-declaration]
  if (readl(p) == 'E' + ('I'<<8) + ('S'<<16) + ('A'<<24))
  ^
../arch/x86/kernel/eisa.c:15:2: error: implicit declaration of function 'iounmap' [-Werror=implicit-function-declaration]
  iounmap(p);
  ^




-- 
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

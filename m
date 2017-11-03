Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0E7186B0033
	for <linux-mm@kvack.org>; Fri,  3 Nov 2017 18:41:46 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id 189so12126453iow.14
        for <linux-mm@kvack.org>; Fri, 03 Nov 2017 15:41:46 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id 10si3408031itz.41.2017.11.03.15.41.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Nov 2017 15:41:44 -0700 (PDT)
Subject: Re: mmotm 2017-11-03-13-00 uploaded
References: <59fccb0b.sRkbr0rZ7jKYyY01%akpm@linux-foundation.org>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <7137ff17-e194-2896-f471-91395b447f59@infradead.org>
Date: Fri, 3 Nov 2017 15:41:35 -0700
MIME-Version: 1.0
In-Reply-To: <59fccb0b.sRkbr0rZ7jKYyY01%akpm@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, mhocko@suse.cz, broonie@kernel.org, X86 ML <x86@kernel.org>

On 11/03/2017 01:01 PM, akpm@linux-foundation.org wrote:
> 
> This mmotm tree contains the following patches against 4.14-rc7:
> (patches marked "*" will be included in linux-next)
> 
>   origin.patch
origin.patch has a problem.  When CONFIG_SMP is not enabled (on x86_64 e.g.):

-	if (cpu_has(c, X86_FEATURE_TSC))
+	if (cpu_has(c, X86_FEATURE_TSC)) {
+		unsigned int freq = arch_freq_get_on_cpu(cpu);


arch/x86/kernel/cpu/proc.o: In function `show_cpuinfo':
proc.c:(.text+0x13d): undefined reference to `arch_freq_get_on_cpu'
/local/lnx/mmotm/mmotm-2017-1103-1300/Makefile:994: recipe for target 'vmlinux' failed


-- 
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

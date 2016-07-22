Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 776EC6B0261
	for <linux-mm@kvack.org>; Fri, 22 Jul 2016 08:26:38 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id b62so76745222pfa.2
        for <linux-mm@kvack.org>; Fri, 22 Jul 2016 05:26:38 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id 4si765713pad.32.2016.07.22.05.26.37
        for <linux-mm@kvack.org>;
        Fri, 22 Jul 2016 05:26:37 -0700 (PDT)
Date: Fri, 22 Jul 2016 20:26:32 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [kbuild-all] [jirislaby-stable:stable-3.12-queue 2253/5333]
 arch/mips/kernel/r4k_switch.S:67: Error: opcode not supported on this
 processor: loongson2e (mips3) `sdc1 $f1, 904($4)'
Message-ID: <20160722122632.GB32690@wfg-t540p.sh.intel.com>
References: <201607221956.UfStWvqZ%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <201607221956.UfStWvqZ%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Jiri Slaby <jslaby@suse.cz>, kbuild-all@01.org, Linux Memory Management List <linux-mm@kvack.org>

>config: mips-fuloong2e_defconfig (attached as .config)
>compiler: mips64el-linux-gnuabi64-gcc (Debian 5.4.0-6) 5.4.0 20160609

>All errors (new ones prefixed by >>):
>
>   arch/mips/kernel/r4k_switch.S: Assembler messages:
>>> arch/mips/kernel/r4k_switch.S:67: Error: opcode not supported on this processor: loongson2e (mips3) `sdc1 $f1,904($4)'
>   arch/mips/kernel/r4k_switch.S:67: Error: opcode not supported on this processor: loongson2e (mips3) `sdc1 $f3,920($4)'
>   arch/mips/kernel/r4k_switch.S:67: Error: opcode not supported on this processor: loongson2e (mips3) `sdc1 $f5,936($4)'
>   arch/mips/kernel/r4k_switch.S:67: Error: opcode not supported on this processor: loongson2e (mips3) `sdc1 $f7,952($4)'

Sorry I'll shut them up -- they obviously should have unique error id
and hence the duplicates be ignored.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

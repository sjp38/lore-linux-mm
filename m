Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f170.google.com (mail-io0-f170.google.com [209.85.223.170])
	by kanga.kvack.org (Postfix) with ESMTP id DB74B6B0255
	for <linux-mm@kvack.org>; Wed,  2 Mar 2016 21:20:38 -0500 (EST)
Received: by mail-io0-f170.google.com with SMTP id m184so12974013iof.1
        for <linux-mm@kvack.org>; Wed, 02 Mar 2016 18:20:38 -0800 (PST)
Received: from heian.cn.fujitsu.com ([59.151.112.132])
        by mx.google.com with ESMTP id 38si8981717ior.180.2016.03.02.18.20.37
        for <linux-mm@kvack.org>;
        Wed, 02 Mar 2016 18:20:38 -0800 (PST)
Message-ID: <56D79EE3.1010705@cn.fujitsu.com>
Date: Thu, 3 Mar 2016 10:18:11 +0800
From: Zhu Guihua <zhugh.fnst@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RESEND PATCH v5 5/5] x86, acpi, cpu-hotplug: Set persistent
 cpuid <-> nodeid mapping when booting.
References: <201603031001.uyaOgVnh%fengguang.wu@intel.com>
In-Reply-To: <201603031001.uyaOgVnh%fengguang.wu@intel.com>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org, cl@linux.com, tj@kernel.org, mika.j.penttila@gmail.com, mingo@redhat.com, akpm@linux-foundation.org, rjw@rjwysocki.net, hpa@zytor.com, yasu.isimatu@gmail.com, isimatu.yasuaki@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, gongzhaogang@inspur.com, len.brown@intel.com, lenb@kernel.org, tglx@linutronix.de, chen.tang@easystack.cn, x86@kernel.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org


On 03/03/2016 10:11 AM, kbuild test robot wrote:
> Hi Gu,
>
> [auto build test ERROR on tip/x86/core]
> [also build test ERROR on v4.5-rc6 next-20160302]
> [if your patch is applied to the wrong git tree, please drop us a note to help improving the system]
>
> url:    https://github.com/0day-ci/linux/commits/Zhu-Guihua/Make-cpuid-nodeid-mapping-persistent/20160303-094713
> config: ia64-allyesconfig (attached as .config)
> reproduce:
>          wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
>          chmod +x ~/bin/make.cross
>          # save the attached .config to linux build tree
>          make.cross ARCH=ia64
>
> All errors (new ones prefixed by >>):
>
>>> arch/ia64/kernel/acpi.c:799:5: error: conflicting types for 'acpi_map_cpu2node'
>      int acpi_map_cpu2node(acpi_handle handle, int cpu, int physid)
>          ^
>     In file included from arch/ia64/kernel/acpi.c:43:0:
>     include/linux/acpi.h:268:6: note: previous declaration of 'acpi_map_cpu2node' was here
>      void acpi_map_cpu2node(acpi_handle handle, int cpu, int physid);
>           ^
>
> vim +/acpi_map_cpu2node +799 arch/ia64/kernel/acpi.c
>
>     793	}
>     794	
>     795	/*
>     796	 *  ACPI based hotplug CPU support
>     797	 */
>     798	#ifdef CONFIG_ACPI_HOTPLUG_CPU
>   > 799	int acpi_map_cpu2node(acpi_handle handle, int cpu, int physid)
>     800	{
>     801	#ifdef CONFIG_ACPI_NUMA
>     802		/*
>
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

Thanks for your test. I will investigate this.

Thanks,
Zhu


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

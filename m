Subject: Re: 2.5.74-mm1 (p4-clockmod does not compile)
From: Dumitru Ciobarcianu <Dumitru.Ciobarcianu@iNES.RO>
In-Reply-To: <20030703023714.55d13934.akpm@osdl.org>
References: <20030703023714.55d13934.akpm@osdl.org>
Content-Type: text/plain
Message-Id: <1057229141.1479.16.camel@LNX.iNES.RO>
Mime-Version: 1.0
Date: 03 Jul 2003 13:45:41 +0300
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Here are the errors:

  CC      arch/i386/kernel/cpu/cpufreq/p4-clockmod.o
arch/i386/kernel/cpu/cpufreq/p4-clockmod.c: In function `cpufreq_p4_setdc':
arch/i386/kernel/cpu/cpufreq/p4-clockmod.c:67: error: incompatible types in assignment
arch/i386/kernel/cpu/cpufreq/p4-clockmod.c:78: error: incompatible type for argument 2 of `set_cpus_allowed'
arch/i386/kernel/cpu/cpufreq/p4-clockmod.c:90: error: incompatible type for argument 2 of `set_cpus_allowed'
arch/i386/kernel/cpu/cpufreq/p4-clockmod.c:131: error: incompatible type for argument 2 of `set_cpus_allowed'
make[3]: *** [arch/i386/kernel/cpu/cpufreq/p4-clockmod.o] Error 1
make[2]: *** [arch/i386/kernel/cpu/cpufreq] Error 2
make[1]: *** [arch/i386/kernel/cpu] Error 2
make: *** [arch/i386/kernel] Error 2




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

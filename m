Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id 236E26B0062
	for <linux-mm@kvack.org>; Mon,  2 Jul 2012 00:58:41 -0400 (EDT)
Message-ID: <4FF12A69.3010705@redhat.com>
Date: Mon, 02 Jul 2012 00:58:17 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 34/40] autonuma: add CONFIG_AUTONUMA and CONFIG_AUTONUMA_DEFAULT_ENABLED
References: <1340888180-15355-1-git-send-email-aarcange@redhat.com> <1340888180-15355-35-git-send-email-aarcange@redhat.com>
In-Reply-To: <1340888180-15355-35-git-send-email-aarcange@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

On 06/28/2012 08:56 AM, Andrea Arcangeli wrote:
> Add the config options to allow building the kernel with AutoNUMA.
>
> If CONFIG_AUTONUMA_DEFAULT_ENABLED is "=y", then
> /sys/kernel/mm/autonuma/enabled will be equal to 1, and AutoNUMA will
> be enabled automatically at boot.
>
> CONFIG_AUTONUMA currently depends on X86, because no other arch
> implements the pte/pmd_numa yet and selecting =y would result in a
> failed build, but this shall be relaxed in the future. Porting
> AutoNUMA to other archs should be pretty simple.
>
> Signed-off-by: Andrea Arcangeli<aarcange@redhat.com>

The Makefile changes could be merged into this patch

> diff --git a/mm/Kconfig b/mm/Kconfig
> index 82fed4e..330dd51 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -207,6 +207,19 @@ config MIGRATION
>   	  pages as migration can relocate pages to satisfy a huge page
>   	  allocation instead of reclaiming.
>
> +config AUTONUMA
> +	bool "Auto NUMA"
> +	select MIGRATION
> +	depends on NUMA&&  X86

How about having the x86 architecture export a
HAVE_AUTONUMA flag, and testing for that?

> +	help
> +	  Automatic NUMA CPU scheduling and memory migration.

This could be expanded to list advantages and
disadvantages of having autonuma enabled.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

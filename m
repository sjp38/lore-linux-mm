Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id 6437B6B006E
	for <linux-mm@kvack.org>; Sat, 30 Jun 2012 01:01:49 -0400 (EDT)
Received: by qadz32 with SMTP id z32so1164275qad.14
        for <linux-mm@kvack.org>; Fri, 29 Jun 2012 22:01:48 -0700 (PDT)
Date: Sat, 30 Jun 2012 01:01:44 -0400
From: Konrad Rzeszutek Wilk <konrad@darnok.org>
Subject: Re: [PATCH 11/40] autonuma: define the autonuma flags
Message-ID: <20120630050143.GD3975@localhost.localdomain>
References: <1340888180-15355-1-git-send-email-aarcange@redhat.com>
 <1340888180-15355-12-git-send-email-aarcange@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1340888180-15355-12-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

On Thu, Jun 28, 2012 at 02:55:51PM +0200, Andrea Arcangeli wrote:
> These flags are the ones tweaked through sysfs, they control the
> behavior of autonuma, from enabling disabling it, to selecting various
> runtime options.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> ---
>  include/linux/autonuma_flags.h |   62 ++++++++++++++++++++++++++++++++++++++++
>  1 files changed, 62 insertions(+), 0 deletions(-)
>  create mode 100644 include/linux/autonuma_flags.h
> 
> diff --git a/include/linux/autonuma_flags.h b/include/linux/autonuma_flags.h
> new file mode 100644
> index 0000000..5e29a75
> --- /dev/null
> +++ b/include/linux/autonuma_flags.h
> @@ -0,0 +1,62 @@
> +#ifndef _LINUX_AUTONUMA_FLAGS_H
> +#define _LINUX_AUTONUMA_FLAGS_H
> +
> +enum autonuma_flag {
> +	AUTONUMA_FLAG,
> +	AUTONUMA_IMPOSSIBLE_FLAG,
> +	AUTONUMA_DEBUG_FLAG,
> +	AUTONUMA_SCHED_LOAD_BALANCE_STRICT_FLAG,
> +	AUTONUMA_SCHED_CLONE_RESET_FLAG,
> +	AUTONUMA_SCHED_FORK_RESET_FLAG,
> +	AUTONUMA_SCAN_PMD_FLAG,
> +	AUTONUMA_SCAN_USE_WORKING_SET_FLAG,
> +	AUTONUMA_MIGRATE_DEFER_FLAG,
> +};
> +
> +extern unsigned long autonuma_flags;

I could not find the this variable in the preceding patches?
Which patch actually uses it?

Also, is there a way to force the AutoNUMA framework
from not initializing at all? Hold that thought, it probably
is in some of the other patches.

> +
> +static inline bool autonuma_enabled(void)
> +{
> +	return !!test_bit(AUTONUMA_FLAG, &autonuma_flags);
> +}
> +
> +static inline bool autonuma_debug(void)
> +{
> +	return !!test_bit(AUTONUMA_DEBUG_FLAG, &autonuma_flags);
> +}
> +
> +static inline bool autonuma_sched_load_balance_strict(void)
> +{
> +	return !!test_bit(AUTONUMA_SCHED_LOAD_BALANCE_STRICT_FLAG,
> +			  &autonuma_flags);
> +}
> +
> +static inline bool autonuma_sched_clone_reset(void)
> +{
> +	return !!test_bit(AUTONUMA_SCHED_CLONE_RESET_FLAG,
> +			  &autonuma_flags);
> +}
> +
> +static inline bool autonuma_sched_fork_reset(void)
> +{
> +	return !!test_bit(AUTONUMA_SCHED_FORK_RESET_FLAG,
> +			  &autonuma_flags);
> +}
> +
> +static inline bool autonuma_scan_pmd(void)
> +{
> +	return !!test_bit(AUTONUMA_SCAN_PMD_FLAG, &autonuma_flags);
> +}
> +
> +static inline bool autonuma_scan_use_working_set(void)
> +{
> +	return !!test_bit(AUTONUMA_SCAN_USE_WORKING_SET_FLAG,
> +			  &autonuma_flags);
> +}
> +
> +static inline bool autonuma_migrate_defer(void)
> +{
> +	return !!test_bit(AUTONUMA_MIGRATE_DEFER_FLAG, &autonuma_flags);
> +}
> +
> +#endif /* _LINUX_AUTONUMA_FLAGS_H */
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

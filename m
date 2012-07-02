Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 01A2D6B0062
	for <linux-mm@kvack.org>; Mon,  2 Jul 2012 00:53:30 -0400 (EDT)
Message-ID: <4FF127F6.9030908@redhat.com>
Date: Mon, 02 Jul 2012 00:47:50 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 30/40] autonuma: numa hinting page faults entry points
References: <1340888180-15355-1-git-send-email-aarcange@redhat.com> <1340888180-15355-31-git-send-email-aarcange@redhat.com>
In-Reply-To: <1340888180-15355-31-git-send-email-aarcange@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

On 06/28/2012 08:56 AM, Andrea Arcangeli wrote:

> +++ b/mm/huge_memory.c
> @@ -1037,6 +1037,23 @@ out:
>   	return page;
>   }
>
> +#ifdef CONFIG_AUTONUMA
> +pmd_t __huge_pmd_numa_fixup(struct mm_struct *mm, unsigned long addr,

This is under CONFIG_AUTONUMA

> +++ b/mm/memory.c

> +static inline pte_t pte_numa_fixup(struct mm_struct *mm,

> +static inline void pmd_numa_fixup(struct mm_struct *mm,

> +static inline pmd_t huge_pmd_numa_fixup(struct mm_struct *mm,

But these are not.  Please fix, or document why this is
not required.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

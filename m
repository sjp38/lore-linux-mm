Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 24A3C6B0073
	for <linux-mm@kvack.org>; Fri, 29 Jun 2012 11:28:10 -0400 (EDT)
Message-ID: <4FEDC961.1060306@redhat.com>
Date: Fri, 29 Jun 2012 11:27:29 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 08/40] autonuma: teach gup_fast about pte_numa
References: <1340888180-15355-1-git-send-email-aarcange@redhat.com> <1340888180-15355-9-git-send-email-aarcange@redhat.com>
In-Reply-To: <1340888180-15355-9-git-send-email-aarcange@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

On 06/28/2012 08:55 AM, Andrea Arcangeli wrote:
> gup_fast will skip over non present ptes (pte_numa requires the pte to
> be non present). So no explicit check is needed for pte_numa in the
> pte case.
>
> gup_fast will also automatically skip over THP when the trans huge pmd
> is non present (pmd_numa requires the pmd to be non present).
>
> But for the special pmd mode scan of knuma_scand
> (/sys/kernel/mm/autonuma/knuma_scand/pmd == 1), the pmd may be of numa
> type (so non present too), the pte may be present. gup_pte_range
> wouldn't notice the pmd is of numa type. So to avoid losing a NUMA
> hinting page fault with gup_fast we need an explicit check for
> pmd_numa() here to be sure it will fault through gup ->
> handle_mm_fault.
>
> Signed-off-by: Andrea Arcangeli<aarcange@redhat.com>

Assuming pmd_numa will get the documentation I asked for a few
patches back, this patch is fine, since people will just be able
to look at a nice comment above pmd_numa and see what is going on.

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id B97816B0083
	for <linux-mm@kvack.org>; Fri, 29 Jun 2012 10:16:49 -0400 (EDT)
Message-ID: <4FEDB8AC.4000209@redhat.com>
Date: Fri, 29 Jun 2012 10:16:12 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 04/40] xen: document Xen is using an unused bit for the
 pagetables
References: <1340888180-15355-1-git-send-email-aarcange@redhat.com> <1340888180-15355-5-git-send-email-aarcange@redhat.com>
In-Reply-To: <1340888180-15355-5-git-send-email-aarcange@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

On 06/28/2012 08:55 AM, Andrea Arcangeli wrote:
> Xen has taken over the last reserved bit available for the pagetables
> which is set through ioremap, this documents it and makes the code
> more readable.
>
> Signed-off-by: Andrea Arcangeli<aarcange@redhat.com>
> ---
>   arch/x86/include/asm/pgtable_types.h |   11 +++++++++--
>   1 files changed, 9 insertions(+), 2 deletions(-)
>
> diff --git a/arch/x86/include/asm/pgtable_types.h b/arch/x86/include/asm/pgtable_types.h
> index 013286a..b74cac9 100644
> --- a/arch/x86/include/asm/pgtable_types.h
> +++ b/arch/x86/include/asm/pgtable_types.h
> @@ -17,7 +17,7 @@
>   #define _PAGE_BIT_PAT		7	/* on 4KB pages */
>   #define _PAGE_BIT_GLOBAL	8	/* Global TLB entry PPro+ */
>   #define _PAGE_BIT_UNUSED1	9	/* available for programmer */
> -#define _PAGE_BIT_IOMAP		10	/* flag used to indicate IO mapping */
> +#define _PAGE_BIT_UNUSED2	10

Considering that Xen is using it, it is not really
unused, is it?

Not that I can think of a better name, considering
you are using this bit for something else at the PMD
level...

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

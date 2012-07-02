Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id AEF676B0062
	for <linux-mm@kvack.org>; Mon,  2 Jul 2012 02:22:45 -0400 (EDT)
Message-ID: <4FF13E0D.6000601@redhat.com>
Date: Mon, 02 Jul 2012 02:22:05 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 37/40] autonuma: page_autonuma change #include for sparse
References: <1340888180-15355-1-git-send-email-aarcange@redhat.com> <1340888180-15355-38-git-send-email-aarcange@redhat.com>
In-Reply-To: <1340888180-15355-38-git-send-email-aarcange@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

On 06/28/2012 08:56 AM, Andrea Arcangeli wrote:
> sparse (make C=1) warns about lookup_page_autonuma not being declared,
> that's a false positive, but we can shut it down by being less strict
> in the includes.
>
> Signed-off-by: Andrea Arcangeli<aarcange@redhat.com>

It is a one line change.  Please fold it into the patch
that introduced the issue, and reduce the size of the
patch series.

> diff --git a/mm/page_autonuma.c b/mm/page_autonuma.c
> index bace9b8..2468c9e 100644
> --- a/mm/page_autonuma.c
> +++ b/mm/page_autonuma.c
> @@ -1,6 +1,6 @@
>   #include<linux/mm.h>
>   #include<linux/memory.h>
> -#include<linux/autonuma_flags.h>
> +#include<linux/autonuma.h>
>   #include<linux/page_autonuma.h>
>   #include<linux/bootmem.h>
>


-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

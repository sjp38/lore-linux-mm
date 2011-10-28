Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 508246B0069
	for <linux-mm@kvack.org>; Fri, 28 Oct 2011 12:08:06 -0400 (EDT)
Message-ID: <4EAAD351.70805@redhat.com>
Date: Fri, 28 Oct 2011 12:07:45 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 4/6] mm: Only IPI CPUs to drain local pages if they
 exist
References: <1319385413-29665-1-git-send-email-gilad@benyossef.com> <1319385413-29665-5-git-send-email-gilad@benyossef.com>
In-Reply-To: <1319385413-29665-5-git-send-email-gilad@benyossef.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gilad Ben-Yossef <gilad@benyossef.com>
Cc: linux-kernel@vger.kernel.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>

On 10/23/2011 11:56 AM, Gilad Ben-Yossef wrote:
> Use a cpumask to track CPUs with per-cpu pages in any zone
> and only send an IPI requesting CPUs to drain these pages
> to the buddy allocator if they actually have pages.

> +/* Which CPUs have per cpu pages  */
> +cpumask_var_t cpus_with_pcp;
> +static DEFINE_PER_CPU(unsigned long, total_cpu_pcp_count);

Does the flushing happen so frequently that it is worth keeping this
state on a per-cpu basis, or would it be better to check each CPU's
pcp info and assemble a cpumask at flush time like done in patch 5?



-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

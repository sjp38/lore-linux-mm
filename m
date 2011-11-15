Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 64D4C6B006E
	for <linux-mm@kvack.org>; Tue, 15 Nov 2011 10:54:58 -0500 (EST)
Date: Tue, 15 Nov 2011 09:54:53 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v3 4/5] slub: Only IPI CPUs that have per cpu obj to
 flush
In-Reply-To: <1321179449-6675-5-git-send-email-gilad@benyossef.com>
Message-ID: <alpine.DEB.2.00.1111150953460.22502@router.home>
References: <1321179449-6675-1-git-send-email-gilad@benyossef.com> <1321179449-6675-5-git-send-email-gilad@benyossef.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gilad Ben-Yossef <gilad@benyossef.com>
Cc: linux-kernel@vger.kernel.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>

On Sun, 13 Nov 2011, Gilad Ben-Yossef wrote:

> @@ -2006,7 +2006,20 @@ static void flush_cpu_slab(void *d)
> +	if (likely(zalloc_cpumask_var(&cpus, GFP_ATOMIC))) {
> +		for_each_online_cpu(cpu) {
> +			c = per_cpu_ptr(s->cpu_slab, cpu);
> +			if (c && c->page)

c will never be null. No need to check.

Otherwise

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 84F026B00F4
	for <linux-mm@kvack.org>; Wed,  9 May 2012 09:47:15 -0400 (EDT)
Date: Wed, 9 May 2012 08:47:12 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Re: [PATCH] slub: Using judgement !!c to judge per cpu has obj
 infucntion has_cpu_slab().
In-Reply-To: <201205090918044843997@gmail.com>
Message-ID: <alpine.DEB.2.00.1205090846100.7720@router.home>
References: <201205080931539844949@gmail.com>, <CAOtvUMctgcCrB_kCoKZki45_2i9XKzp-XLyfmNTxYwdFWSKYNQ@mail.gmail.com>, <alpine.DEB.2.00.1205080909490.25669@router.home> <201205090918044843997@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: majianpeng <majianpeng@gmail.com>
Cc: Gilad Ben-Yossef <gilad@benyossef.com>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>

On Wed, 9 May 2012, majianpeng wrote:

> Commit a8364d5555b2030d093cde0f0795 modified flush_all to only
> send IPI to flush per-cpu cache pages to CPUs that seems to have done.

Add some information as to why this happened to the changelog please. The
commit did not include checks for per cpu partial pages being present on a
cpu.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

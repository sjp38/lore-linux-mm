Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id 007406B0031
	for <linux-mm@kvack.org>; Fri, 19 Jul 2013 11:52:07 -0400 (EDT)
Message-ID: <51E9609D.4030201@sr71.net>
Date: Fri, 19 Jul 2013 08:51:57 -0700
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [RESEND][PATCH] mm: vmstats: tlb flush counters
References: <20130716234438.C792C316@viggo.jf.intel.com> <20130717072100.GA14359@gmail.com> <20130718135157.2262e28b2c6e0f43a4d0fe7a@linux-foundation.org> <20130719082848.GA25784@gmail.com>
In-Reply-To: <20130719082848.GA25784@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>

On 07/19/2013 01:28 AM, Ingo Molnar wrote:
> UP is slowly going extinct, but in any case these counters ought to inform 
> us about TLB flushes even on UP systems:
> 
>>>> > > > +		NR_TLB_LOCAL_FLUSH_ALL,
>>>> > > > +		NR_TLB_LOCAL_FLUSH_ONE,
>>>> > > > +		NR_TLB_LOCAL_FLUSH_ONE_KERNEL,
> While these ought to be compiled out on UP kernels:
> 
>>>> > > > +		NR_TLB_REMOTE_FLUSH,	/* cpu tried to flush others' tlbs */
>>>> > > > +		NR_TLB_REMOTE_FLUSH_RECEIVED,/* cpu received ipi for flush */
> Right?

Yeah, it's useful on UP too.  But I realized that my changes were
confined to the SMP code.  The UP code is almost all in one of the
headers, and I didn't touch it.  So I've got some work there to fix it up.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

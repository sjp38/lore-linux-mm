Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id B14916B0032
	for <linux-mm@kvack.org>; Mon, 22 Jul 2013 12:59:51 -0400 (EDT)
Message-ID: <51ED64FC.8090104@sr71.net>
Date: Mon, 22 Jul 2013 09:59:40 -0700
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [RESEND][PATCH] mm: vmstats: tlb flush counters
References: <20130716234438.C792C316@viggo.jf.intel.com> <CAC4Lta1mHixqfRSJKpydH3X9M_nQPCY3QSD86Tm=cnQ+KxpGYw@mail.gmail.com> <51E95932.5030902@sr71.net> <20130722100605.GA1148@gmail.com>
In-Reply-To: <20130722100605.GA1148@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Raghavendra KT <raghavendra.kt.linux@gmail.com>, linux-kernel@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org, Raghavendra KT <raghavendra.kt@linux.vnet.ibm.com>

On 07/22/2013 03:06 AM, Ingo Molnar wrote:
> Btw., would be nice to also integrate these VM counters into perf as well, 
> as an instrumentation variant/option.
> 
> It could be done in an almost zero overhead fashion using jump-labels I 
> think.
> 
> [ Just in case someone is bored to death and is looking for an interesting 
>   side project ;-) ]

I'd actually been thinking about making them in to tracepoints, but the
tracepoint macros seem to create #include messes if you try to use them
in very common headers.

Agree it would be an interesting side project, though. :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

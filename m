Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id C30846B0032
	for <linux-mm@kvack.org>; Tue, 23 Jul 2013 04:17:31 -0400 (EDT)
Received: by mail-ee0-f43.google.com with SMTP id l10so4262491eei.16
        for <linux-mm@kvack.org>; Tue, 23 Jul 2013 01:17:30 -0700 (PDT)
Date: Tue, 23 Jul 2013 10:17:27 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [RESEND][PATCH] mm: vmstats: tlb flush counters
Message-ID: <20130723081727.GB16088@gmail.com>
References: <20130716234438.C792C316@viggo.jf.intel.com>
 <CAC4Lta1mHixqfRSJKpydH3X9M_nQPCY3QSD86Tm=cnQ+KxpGYw@mail.gmail.com>
 <51E95932.5030902@sr71.net>
 <20130722100605.GA1148@gmail.com>
 <51ED64FC.8090104@sr71.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51ED64FC.8090104@sr71.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: Raghavendra KT <raghavendra.kt.linux@gmail.com>, linux-kernel@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org, Raghavendra KT <raghavendra.kt@linux.vnet.ibm.com>


* Dave Hansen <dave@sr71.net> wrote:

> On 07/22/2013 03:06 AM, Ingo Molnar wrote:
> > Btw., would be nice to also integrate these VM counters into perf as well, 
> > as an instrumentation variant/option.
> > 
> > It could be done in an almost zero overhead fashion using jump-labels I 
> > think.
> > 
> > [ Just in case someone is bored to death and is looking for an interesting 
> >   side project ;-) ]
> 
> I'd actually been thinking about making them in to tracepoints, but the 
> tracepoint macros seem to create #include messes if you try to use them 
> in very common headers.
> 
> Agree it would be an interesting side project, though. :)

Yes, tracepoints was what I was thinking about, it would allow easy 
integration into perf [and it's useful even without any userspace side] - 
as long as:

 - the tracepoints trace the counts/sums, not just the events themselves
 - when the tracepoints are not active the VM counts are still maintained 
   separately

I.e. the existing VM counts and its extraction facilities are not impacted 
in any way, just a new channel of instrumentation is provided - 
jump-label/static-key optimized by virtue of being tracepoints.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

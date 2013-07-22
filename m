Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 68A9A6B0032
	for <linux-mm@kvack.org>; Mon, 22 Jul 2013 06:06:10 -0400 (EDT)
Received: by mail-ee0-f43.google.com with SMTP id l10so3662082eei.16
        for <linux-mm@kvack.org>; Mon, 22 Jul 2013 03:06:08 -0700 (PDT)
Date: Mon, 22 Jul 2013 12:06:06 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [RESEND][PATCH] mm: vmstats: tlb flush counters
Message-ID: <20130722100605.GA1148@gmail.com>
References: <20130716234438.C792C316@viggo.jf.intel.com>
 <CAC4Lta1mHixqfRSJKpydH3X9M_nQPCY3QSD86Tm=cnQ+KxpGYw@mail.gmail.com>
 <51E95932.5030902@sr71.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51E95932.5030902@sr71.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: Raghavendra KT <raghavendra.kt.linux@gmail.com>, linux-kernel@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org, Raghavendra KT <raghavendra.kt@linux.vnet.ibm.com>


* Dave Hansen <dave@sr71.net> wrote:

> On 07/19/2013 04:38 AM, Raghavendra KT wrote:
> > While measuring non - PLE performance, one of the bottleneck, I am seeing is
> > flush tlbs.
> > perf had helped in alaysing a bit there, but this patch would help
> > in precise calculation. It will aslo help in tuning the PLE window
> > experiments (larger PLE window
> > would affect remote flush TLBs)
> 
> Interesting.  What workload is that?  I've been having problems finding
> workloads that are too consumed with TLB flushes.

Btw., would be nice to also integrate these VM counters into perf as well, 
as an instrumentation variant/option.

It could be done in an almost zero overhead fashion using jump-labels I 
think.

[ Just in case someone is bored to death and is looking for an interesting 
  side project ;-) ]

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

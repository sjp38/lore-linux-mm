Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 2911C6B0032
	for <linux-mm@kvack.org>; Fri, 19 Jul 2013 11:20:29 -0400 (EDT)
Message-ID: <51E95932.5030902@sr71.net>
Date: Fri, 19 Jul 2013 08:20:18 -0700
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [RESEND][PATCH] mm: vmstats: tlb flush counters
References: <20130716234438.C792C316@viggo.jf.intel.com> <CAC4Lta1mHixqfRSJKpydH3X9M_nQPCY3QSD86Tm=cnQ+KxpGYw@mail.gmail.com>
In-Reply-To: <CAC4Lta1mHixqfRSJKpydH3X9M_nQPCY3QSD86Tm=cnQ+KxpGYw@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Raghavendra KT <raghavendra.kt.linux@gmail.com>
Cc: linux-kernel@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org, Raghavendra KT <raghavendra.kt@linux.vnet.ibm.com>

On 07/19/2013 04:38 AM, Raghavendra KT wrote:
> While measuring non - PLE performance, one of the bottleneck, I am seeing is
> flush tlbs.
> perf had helped in alaysing a bit there, but this patch would help
> in precise calculation. It will aslo help in tuning the PLE window
> experiments (larger PLE window
> would affect remote flush TLBs)

Interesting.  What workload is that?  I've been having problems finding
workloads that are too consumed with TLB flushes.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

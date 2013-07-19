Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 7EC9C6B0033
	for <linux-mm@kvack.org>; Fri, 19 Jul 2013 07:38:05 -0400 (EDT)
Received: by mail-wg0-f47.google.com with SMTP id l18so3813896wgh.2
        for <linux-mm@kvack.org>; Fri, 19 Jul 2013 04:38:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130716234438.C792C316@viggo.jf.intel.com>
References: <20130716234438.C792C316@viggo.jf.intel.com>
Date: Fri, 19 Jul 2013 17:08:03 +0530
Message-ID: <CAC4Lta1mHixqfRSJKpydH3X9M_nQPCY3QSD86Tm=cnQ+KxpGYw@mail.gmail.com>
Subject: Re: [RESEND][PATCH] mm: vmstats: tlb flush counters
From: Raghavendra KT <raghavendra.kt.linux@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-kernel@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org, Raghavendra KT <raghavendra.kt@linux.vnet.ibm.com>

On Wed, Jul 17, 2013 at 5:14 AM, Dave Hansen <dave@sr71.net> wrote:
>
> I was investigating some TLB flush scaling issues and realized
> that we do not have any good methods for figuring out how many
> TLB flushes we are doing.
>
> It would be nice to be able to do these in generic code, but the
> arch-independent calls don't explicitly specify whether we
> actually need to do remote flushes or not.  In the end, we really
> need to know if we actually _did_ global vs. local invalidations,
> so that leaves us with few options other than to muck with the
> counters from arch-specific code.
>
> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
> ---

Hi Dave,
While measuring non - PLE performance, one of the bottleneck, I am seeing is
flush tlbs.
perf had helped in alaysing a bit there, but this patch would help
in precise calculation. It will aslo help in tuning the PLE window
experiments (larger PLE window
would affect remote flush TLBs)

Thanks for this patch. Tested the patch on my sandybridge.box

Tested-by: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

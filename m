Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id D96946B0035
	for <linux-mm@kvack.org>; Fri, 22 Aug 2014 14:12:38 -0400 (EDT)
Received: by mail-pd0-f182.google.com with SMTP id fp1so16534570pdb.13
        for <linux-mm@kvack.org>; Fri, 22 Aug 2014 11:12:38 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id i8si41941557pdn.177.2014.08.22.11.12.37
        for <linux-mm@kvack.org>;
        Fri, 22 Aug 2014 11:12:37 -0700 (PDT)
Subject: Re: [PATCH] [v3] warn on performance-impacting configs aka.
 TAINT_PERFORMANCE
From: Tim Chen <tim.c.chen@linux.intel.com>
In-Reply-To: <53F773A2.7040904@sr71.net>
References: <20140821202424.7ED66A50@viggo.jf.intel.com>
	 <1408725157.4347.14.camel@schen9-DESK>  <53F773A2.7040904@sr71.net>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 22 Aug 2014 11:12:40 -0700
Message-ID: <1408731160.4347.26.camel@schen9-DESK>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-kernel@vger.kernel.org, dave.hansen@linux.intel.com, peterz@infradead.org, mingo@redhat.com, ak@linux.intel.com, akpm@linux-foundation.org, cl@linux.com, penberg@kernel.org, linux-mm@kvack.org, kirill@shutemov.name, lauraa@codeaurora.org

On Fri, 2014-08-22 at 09:45 -0700, Dave Hansen wrote:
> On 08/22/2014 09:32 AM, Tim Chen wrote:
> >> > +#ifdef CONFIG_DEBUG_OBJECTS_FREE
> >> > +	"DEBUG_OBJECTS_FREE",
> >> > +#endif
> >> > +#ifdef CONFIG_DEBUG_KMEMLEAK
> >> > +	"DEBUG_KMEMLEAK",
> >> > +#endif
> >> > +#ifdef CONFIG_DEBUG_PAGEALLOC
> >> > +	"DEBUG_PAGEALLOC",
> > I think coverage profiling also impact performance.
> > So I sould also put CONFIG_GCOV_KERNEL in the list.
> 
> Would CONFIG_GCOV_PROFILE_ALL be the better one to check?  With plain
> GCOV_KERNEL, I don't think we will, by default, put the coverage
> information in any files and slow them down.

CONFIG_GCOV_PROFILE_ALL is definitely a no no regarding to
performance impact, which is mentioned in the gcov documentation.

I haven't tested this, but if profiling is turned on only for
a piece of code that is performance critical but not for
the whole kernel, in theory performance can still be impacted
with the overhead.  So I think it is safer to check
for CONFIG_GCOV_KERNEL, that has no reason to be turned on
for any workload that's performance critical.

Tim


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

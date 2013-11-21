Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f174.google.com (mail-we0-f174.google.com [74.125.82.174])
	by kanga.kvack.org (Postfix) with ESMTP id 966716B0031
	for <linux-mm@kvack.org>; Thu, 21 Nov 2013 03:15:44 -0500 (EST)
Received: by mail-we0-f174.google.com with SMTP id q58so4480552wes.5
        for <linux-mm@kvack.org>; Thu, 21 Nov 2013 00:15:43 -0800 (PST)
Received: from radon.swed.at (b.ns.miles-group.at. [95.130.255.144])
        by mx.google.com with ESMTPS id x19si429617wie.11.2013.11.21.00.15.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 21 Nov 2013 00:15:43 -0800 (PST)
From: Richard Weinberger <richard@nod.at>
Subject: Re: mmotm 2013-11-20-16-13 uploaded (arch/um/kernel/sysrq.c)
Date: Thu, 21 Nov 2013 09:15:38 +0100
Message-ID: <4049956.nmFOrVzcI3@sandpuppy>
In-Reply-To: <528D5935.6070907@infradead.org>
References: <20131121001408.17DC85A41C6@corp2gmr1-2.hot.corp.google.com> <528D5935.6070907@infradead.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@infradead.org>
Cc: akpm@linux-foundation.org, mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, user-mode-linux-devel@lists.sourceforge.net

Am Mittwoch, 20. November 2013, 16:52:05 schrieb Randy Dunlap:
> On 11/20/13 16:14, akpm@linux-foundation.org wrote:
> > The mm-of-the-moment snapshot 2013-11-20-16-13 has been uploaded to
> > 
> >    http://www.ozlabs.org/~akpm/mmotm/
> > 
> > mmotm-readme.txt says
> > 
> > README for mm-of-the-moment:
> > 
> > http://www.ozlabs.org/~akpm/mmotm/
> > 
> > This is a snapshot of my -mm patch queue.  Uploaded at random hopefully
> > more than once a week.
> 
> on i386:
> (with um i386 defconfig)
> 
> arch/um/kernel/sysrq.c:22:13: error: expected identifier or '(' before 'do'
> um/kernel/sysrq.c:22:13: error: expected identifier or '(' before 'while'
> 
> 
> so sysrq.c is picking up <linux/stacktrace.h> somehow and not liking it.

um/kernel/sysrq.c has
static void print_stack_trace(unsigned long *sp, unsigned long bp)
and linux/stracktrace.h has
# define print_stack_trace(trace, spaces)               do { } while (0)

So um's print_stack_trace needs to be renamed.
Thanks a lot for reporting!

Thanks,
//richard

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f174.google.com (mail-we0-f174.google.com [74.125.82.174])
	by kanga.kvack.org (Postfix) with ESMTP id 8DE3A900015
	for <linux-mm@kvack.org>; Thu, 19 Mar 2015 13:11:16 -0400 (EDT)
Received: by wetk59 with SMTP id k59so62739746wet.3
        for <linux-mm@kvack.org>; Thu, 19 Mar 2015 10:11:16 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id qs6si3302042wjc.68.2015.03.19.10.11.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 19 Mar 2015 10:11:15 -0700 (PDT)
Date: Thu, 19 Mar 2015 09:38:27 -0700
From: Shaohua Li <shli@fb.com>
Subject: Re: [PATCH] mremap: add MREMAP_NOHOLE flag --resend
Message-ID: <20150319163827.GA3006724@devbig257.prn2.facebook.com>
References: <deaa4139de6e6422a0cec1e3282553aed3495e94.1426626497.git.shli@fb.com>
 <20150318153100.5658b741277f3717b52e42d9@linux-foundation.org>
 <20150319050826.GA1591708@devbig257.prn2.facebook.com>
 <20150318222246.bc608dd0.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20150318222246.bc608dd0.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, danielmicay@gmail.com, linux-api@vger.kernel.org, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Andy Lutomirski <luto@amacapital.net>

On Wed, Mar 18, 2015 at 10:22:46PM -0700, Andrew Morton wrote:
> On Wed, 18 Mar 2015 22:08:26 -0700 Shaohua Li <shli@fb.com> wrote:
> 
> > > Daniel also had microbenchmark testing results for glibc and jemalloc. 
> > > Can you please do this?
> > 
> > I run Daniel's microbenchmark too, and not surprise the result is
> > similar:
> > glibc: 32.82
> > jemalloc: 70.35
> > jemalloc+mremap: 33.01
> > tcmalloc: 68.81
> > 
> > but tcmalloc doesn't support mremap currently, so I cant test it.
> 
> But Daniel's changelog implies strongly that tcmalloc would benefit
> from his patch.  Was that inaccurate or is this a difference between
> his patch and yours?

There is no big difference, except I fixed some issues. Daniel didn't
post data for tcmalloc, I suppose it's potential mremap can make
tcmalloc faster too, but Daniel can clarify.

Thanks,
Shaohua

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

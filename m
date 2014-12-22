Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f52.google.com (mail-qg0-f52.google.com [209.85.192.52])
	by kanga.kvack.org (Postfix) with ESMTP id 16C8A6B0071
	for <linux-mm@kvack.org>; Mon, 22 Dec 2014 12:36:41 -0500 (EST)
Received: by mail-qg0-f52.google.com with SMTP id a108so3521601qge.25
        for <linux-mm@kvack.org>; Mon, 22 Dec 2014 09:36:40 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j7si20642868qce.45.2014.12.22.09.36.38
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Dec 2014 09:36:39 -0800 (PST)
Date: Mon, 22 Dec 2014 12:25:00 -0500
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [PATCH] proc: task_mmu: show page size in /proc/<pid>/numa_maps
Message-ID: <20141222172459.GA11396@t510.redhat.com>
References: <c97f30472ec5fe79cb8fa8be66cc3d8509777990.1419079617.git.aquini@redhat.com>
 <20141220183613.GA19229@phnom.home.cmpxchg.org>
 <20141220194457.GA3166@x61.redhat.com>
 <54970B49.3070104@linux.intel.com>
 <20141221222850.GA2038@x61.redhat.com>
 <5498508A.4080108@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5498508A.4080108@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, oleg@redhat.com, rientjes@google.com, linux-mm@kvack.org

On Mon, Dec 22, 2014 at 09:10:34AM -0800, Dave Hansen wrote:
> On 12/21/2014 02:28 PM, Rafael Aquini wrote:
> >>> > > I'm fine either way, it makes the change even simpler. Also, if we
> >>> > > decide to get rid of page_size != PAGE_SIZE condition I believe we can 
> >>> > > also get rid of that "huge" hint being conditionally printed out too.
> >> > 
> >> > That would break existing users of the "huge" flag.  That makes it out
> >> > of the question, right?
> >> >
> > Yeah, but it sort of follows the same complaint Johannes did for the 
> > conditional page size printouts. If we start to print out page size
> > deliberately for each map regardless their backing pages being PAGE_SIZE 
> > long or bigger, I don't see much point on keep conditionally printing out 
> > the 'huge' hint out.
> 
> Because existing userspace might be relying on it.  If we take the
> 'huge' hint out, userspace will break.
> 
> > As I said before, I'm fine either way though I think
> > we can keep the current behaviour, and just disambiguate page sizes !=
> > PAGE_SIZE as in the current proposal.
> 
> Unless we somehow have a (really good) handle on how many apps out there
> are reading and using 'huge', I think we have to keep the existing behavior.
>
Right. I definitely don't have anything better than what I already
presented which seems beaten by your argument, already. 
Remaining question here is: should we print out 'pagesize' deliberately 
or conditionally, only to disambiguate cases where page_size != PAGE_SIZE?

Have a very nice holidays folks!
-- Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id C9C606B0071
	for <linux-mm@kvack.org>; Mon, 22 Dec 2014 12:59:41 -0500 (EST)
Received: by mail-pa0-f51.google.com with SMTP id ey11so6357065pad.10
        for <linux-mm@kvack.org>; Mon, 22 Dec 2014 09:59:41 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id pn5si26096594pbb.72.2014.12.22.09.59.39
        for <linux-mm@kvack.org>;
        Mon, 22 Dec 2014 09:59:40 -0800 (PST)
Message-ID: <54985C08.8080608@linux.intel.com>
Date: Mon, 22 Dec 2014 09:59:36 -0800
From: Dave Hansen <dave.hansen@linux.intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH] proc: task_mmu: show page size in /proc/<pid>/numa_maps
References: <c97f30472ec5fe79cb8fa8be66cc3d8509777990.1419079617.git.aquini@redhat.com> <20141220183613.GA19229@phnom.home.cmpxchg.org> <20141220194457.GA3166@x61.redhat.com> <54970B49.3070104@linux.intel.com> <20141221222850.GA2038@x61.redhat.com> <5498508A.4080108@linux.intel.com> <20141222172459.GA11396@t510.redhat.com>
In-Reply-To: <20141222172459.GA11396@t510.redhat.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rafael Aquini <aquini@redhat.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, oleg@redhat.com, rientjes@google.com, linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

On 12/22/2014 09:25 AM, Rafael Aquini wrote:
> Remaining question here is: should we print out 'pagesize' deliberately 
> or conditionally, only to disambiguate cases where page_size != PAGE_SIZE?

I say print it unconditionally.  Not to completely overdesign this, but
I do think we should try to at least mirror the terminology that smaps uses:

	KernelPageSize:        4 kB
	MMUPageSize:           4 kB

So definitely call this kernelpagesize.

It appears that powerpc is the only architecture where there is a
difference, and I'm not sure that this is very common at all these days.
 Do we need mmupagesize in numa_maps too?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 751F36B0036
	for <linux-mm@kvack.org>; Mon,  4 Nov 2013 02:05:06 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id lf10so6568825pab.34
        for <linux-mm@kvack.org>; Sun, 03 Nov 2013 23:05:06 -0800 (PST)
Received: from psmtp.com ([74.125.245.113])
        by mx.google.com with SMTP id it5si9740747pbc.95.2013.11.03.23.05.04
        for <linux-mm@kvack.org>;
        Sun, 03 Nov 2013 23:05:05 -0800 (PST)
Received: by mail-ee0-f54.google.com with SMTP id c50so905117eek.27
        for <linux-mm@kvack.org>; Sun, 03 Nov 2013 23:05:02 -0800 (PST)
Date: Mon, 4 Nov 2013 08:05:00 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH] mm: cache largest vma
Message-ID: <20131104070500.GE13030@gmail.com>
References: <1383337039.2653.18.camel@buesod1.americas.hpqcorp.net>
 <20131103101234.GB5330@gmail.com>
 <1383538810.2373.22.camel@buesod1.americas.hpqcorp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1383538810.2373.22.camel@buesod1.americas.hpqcorp.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>, =?iso-8859-1?Q?Fr=E9d=E9ric?= Weisbecker <fweisbec@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Michel Lespinasse <walken@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Guan Xuetao <gxt@mprc.pku.edu.cn>, aswin@hp.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>


* Davidlohr Bueso <davidlohr@hp.com> wrote:

> Btw, do you suggest using a high level tool such as perf for getting 
> this data or sprinkling get_cycles() in find_vma() -- I'd think that the 
> first isn't fine grained enough, while the later will probably variate a 
> lot from run to run but the ratio should be rather constant.

LOL - I guess I should have read your mail before replying to it ;-)

Yes, I think get_cycles() works better in this case - not due to 
granularity (perf stat will report cycle granular just fine), but due to 
the size of the critical path you'll be measuring. You really want to 
extract the delta, because it's probably so much smaller than the overhead 
of the workload itself.

[ We still don't have good 'measure overhead from instruction X to 
  instruction Y' delta measurement infrastructure in perf yet, although
  Frederic is working on such a trigger/delta facility AFAIK. ]

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

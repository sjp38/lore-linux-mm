Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 407286B0071
	for <linux-mm@kvack.org>; Fri, 26 Oct 2012 05:20:54 -0400 (EDT)
Received: by mail-wi0-f179.google.com with SMTP id hq7so177574wib.8
        for <linux-mm@kvack.org>; Fri, 26 Oct 2012 02:20:52 -0700 (PDT)
Date: Fri, 26 Oct 2012 11:20:48 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 00/31] numa/core patches
Message-ID: <20121026092048.GA628@gmail.com>
References: <20121025121617.617683848@chello.nl>
 <508A52E1.8020203@redhat.com>
 <1351242480.12171.48.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1351242480.12171.48.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Zhouping Liu <zliu@redhat.com>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org


* Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:

> On Fri, 2012-10-26 at 17:07 +0800, Zhouping Liu wrote:
> > [  180.918591] RIP: 0010:[<ffffffff8118c39a>]  [<ffffffff8118c39a>] mem_cgroup_prepare_migration+0xba/0xd0
> 
> > [  182.681450]  [<ffffffff81183b60>] do_huge_pmd_numa_page+0x180/0x500
> > [  182.775090]  [<ffffffff811585c9>] handle_mm_fault+0x1e9/0x360
> > [  182.863038]  [<ffffffff81632b62>] __do_page_fault+0x172/0x4e0
> > [  182.950574]  [<ffffffff8101c283>] ? __switch_to_xtra+0x163/0x1a0
> > [  183.041512]  [<ffffffff8101281e>] ? __switch_to+0x3ce/0x4a0
> > [  183.126832]  [<ffffffff8162d686>] ? __schedule+0x3c6/0x7a0
> > [  183.211216]  [<ffffffff81632ede>] do_page_fault+0xe/0x10
> > [  183.293705]  [<ffffffff8162f518>] page_fault+0x28/0x30 
> 
> Johannes, this looks like the thp migration memcg hookery gone bad,
> could you have a look at this?

Meanwhile, Zhouping Liu, could you please not apply the last 
patch:

  [PATCH] sched, numa, mm: Add memcg support to do_huge_pmd_numa_page()

and see whether it boots/works without that?

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

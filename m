Date: Wed, 25 Jul 2007 10:28:22 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: -mm merge plans for 2.6.23
Message-ID: <20070725082822.GA13098@elte.hu>
References: <46A57068.3070701@yahoo.com.au> <2c0942db0707232153j3670ef31kae3907dff1a24cb7@mail.gmail.com> <46A58B49.3050508@yahoo.com.au> <2c0942db0707240915h56e007e3l9110e24a065f2e73@mail.gmail.com> <46A6CC56.6040307@yahoo.com.au> <46A6D7D2.4050708@gmail.com> <Pine.LNX.4.64.0707242211210.2229@asgard.lang.hm> <46A6DFFD.9030202@gmail.com> <30701.1185347660@turing-police.cc.vt.edu> <46A7074B.50608@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <46A7074B.50608@gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rene Herman <rene.herman@gmail.com>
Cc: Valdis.Kletnieks@vt.edu, david@lang.hm, Nick Piggin <nickpiggin@yahoo.com.au>, Ray Lee <ray-lk@madrabbit.org>, Jesper Juhl <jesper.juhl@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, ck list <ck@vds.kolivas.org>, Paul Jackson <pj@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

* Rene Herman <rene.herman@gmail.com> wrote:

> Regardless, I'll stand by "[by disabling updatedb] the problem will 
> for a large part be solved" as I expect approximately 94.372 percent 
> of Linux desktop users couldn't care less about locate.

i think that approach is illogical: because Linux mis-handled a mixed 
workload the answer is to ... remove a portion of that workload?

To bring your approach to the extreme: what if Linux sucked at running 
more than two CPU-intense tasks at once. Most desktop users dont do 
that, so a probably larger than 94.372 percent of Linux desktop users 
couldn't care less about a proper scheduler. Still, anyone who builds a 
kernel (the average desktop user wont do that) while using firefox will 
attest to the fact that it's quite handy that the Linux scheduler can 
handle mixed workloads pretty well.

now, it might be the case that this mixed VM/VFS workload cannot be 
handled any more intelligently - but that wasnt your argument! The 
swap-prefetch patch certainly tried to do things more intelligently and 
the test-case (measurement app) Con provided showed visible improvements 
in swap-in latency. (and a good number of people posted those results)

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

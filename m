Date: Sat, 4 Aug 2007 09:07:37 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 00/23] per device dirty throttling -v8
Message-ID: <20070804070737.GA940@elte.hu>
References: <20070803123712.987126000@chello.nl> <alpine.LFD.0.999.0708031518440.8184@woody.linux-foundation.org> <20070804063217.GA25069@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070804063217.GA25069@elte.hu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, richard@rsk.demon.co.uk
List-ID: <linux-mm.kvack.org>

* Ingo Molnar <mingo@elte.hu> wrote:

> There are positive reports in the never-ending "my system crawls like 
> an XT when copying large files" bugzilla entry:
> 
>  http://bugzilla.kernel.org/show_bug.cgi?id=7372

i forgot this entry:

 " We recently upgraded our office to gigabit Ethernet and got some big 
   AMD64 / 3ware boxes for file and vmware servers... only to find them 
   almost useless under any kind of real load. I've built some patched 
   2.6.21.6 kernels (using the bdi throttling patch you mentioned) to 
   see if our various Debian Etch boxes run better. So far my testing 
   shows a *great* improvement over the stock Debian 2.6.18 kernel on 
   our configurations. "

and bdi has been in -mm in the past i think, so we also know (to a 
certain degree) that it does not hurt those workloads that are fine 
either.

[ my personal interest in this is the following regression: every time i
  start a large kernel build with DEBUG_INFO on a quad-core 4GB RAM box,
  i get up to 30 seconds complete pauses in Vim (and most other tasks),
  during plain editing of the source code. (which happens when Vim tries
  to write() to its swap/undo-file.) ]

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

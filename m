Date: Sat, 4 Aug 2007 18:37:33 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 00/23] per device dirty throttling -v8
Message-ID: <20070804163733.GA31001@elte.hu>
References: <20070803123712.987126000@chello.nl> <alpine.LFD.0.999.0708031518440.8184@woody.linux-foundation.org> <20070804063217.GA25069@elte.hu> <20070804070737.GA940@elte.hu> <20070804103347.GA1956@elte.hu> <alpine.LFD.0.999.0708040915360.5037@woody.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.0.999.0708040915360.5037@woody.linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, richard@rsk.demon.co.uk
List-ID: <linux-mm.kvack.org>

* Linus Torvalds <torvalds@linux-foundation.org> wrote:

> > hm, it turns out that it's due to vim doing an occasional fsync not 
> > only on writeout, but during normal use too. "set nofsync" in the 
> > .vimrc solves this problem.
> 
> Yes, that's independent. The fact is, ext3 *sucks* at fsync. I hate 
> hate hate it. It's totally unusable, imnsho.

yeah, it's really ugly. But otherwise i've got no real complaint about 
ext3 - with the obligatory qualification that "noatime,nodiratime" in 
/etc/fstab is a must. This speeds up things very visibly - especially 
when lots of files are accessed. It's kind of weird that every Linux 
desktop and server is hurt by a noticeable IO performance slowdown due 
to the constant atime updates, while there's just two real users of it: 
tmpwatch [which can be configured to use ctime so it's not a big issue] 
and some backup tools. (Ok, and mail-notify too i guess.) Out of tens of 
thousands of applications. So for most file workloads we give Windows a 
20%-30% performance edge, for almost nothing. (for RAM-starved kernel 
builds the performance difference between atime and noatime+nodiratime 
setups is more on the order of 40%)

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

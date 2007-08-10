Message-ID: <46BBAF82.7020702@tmr.com>
Date: Thu, 09 Aug 2007 20:21:22 -0400
From: Bill Davidsen <davidsen@tmr.com>
MIME-Version: 1.0
Subject: Re: [PATCH 00/23] per device dirty throttling -v8
References: <20070804070737.GA940@elte.hu>	<20070804103347.GA1956@elte.hu>	<alpine.LFD.0.999.0708040915360.5037@woody.linux-foundation.org>	<20070804163733.GA31001@elte.hu>	<alpine.LFD.0.999.0708041030040.5037@woody.linux-foundation.org>	<46B4C0A8.1000902@garzik.org>	<20070804191205.GA24723@lazybastard.org>	<20070804192130.GA25346@elte.hu>	<20070804192615.GA25600@lazybastard.org>	<20070804194259.GA25753@lazybastard.org>	<20070805203602.GB25107@infradead.org>	<46BA3137.3020701@mbligh.org> <20070808142146.c85ab8d7.akpm@linux-foundation.org>
In-Reply-To: <20070808142146.c85ab8d7.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Martin J. Bligh" <mbligh@mbligh.org>, Christoph Hellwig <hch@infradead.org>, J??rn Engel <joern@logfs.org>, Ingo Molnar <mingo@elte.hu>, Jeff Garzik <jeff@garzik.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, miklos@szeredi.hu, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, richard@rsk.demon.co.uk, david@lang.hm
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> On Wed, 08 Aug 2007 14:10:15 -0700
> "Martin J. Bligh" <mbligh@mbligh.org> wrote:
> 
>> Why isn't this easily fixable by just adding an additional dirty
>> flag that says atime has changed? Then we only cause a write
>> when we remove the inode from the inode cache, if only atime
>> is updated.
> 
> I think that could be made to work, and it would fix the performance
> issue.
> 
> It is a behaviour change.  At present ext3 (for example) commits everything
> every five seconds.  After a change like this, a crash+recovery could cause
> a file's atime to go backwards by an arbitrarily large time interval - it
> could easily be months.
> 
I would think that (really) updating atime on open would be enough, 
hopefully without being too much. The "lazyatime" thing I was playing 
with only updated on open, final close, write, and fork.

I like the idea of updating once in a while, but one of the benefits of 
noatime is allowing drives to spin down via inactivity. If something 
does get done in the area of less but non-zero atime tracking, perhaps 
that could be taken into account. I have to check what "laptop_mode 
actually does, since my laptops are old installs.

-- 
Bill Davidsen <davidsen@tmr.com>
   "We have more to fear from the bungling of the incompetent than from
the machinations of the wicked."  - from Slashdot

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

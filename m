Subject: Re: [-mm][PATCH 0/10]  memory related bugfix set for
	2.6.26-rc5-mm3 v2
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20080625185717.D84C.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20080625185717.D84C.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Content-Type: text/plain
Date: Wed, 25 Jun 2008 11:09:31 -0400
Message-Id: <1214406571.7010.21.camel@lts-notebook>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2008-06-25 at 18:59 +0900, KOSAKI Motohiro wrote:
> Hi, Andrew and mm guys!
> 
> this is mm related fixes patchset for 2.6.26-rc5-mm3 v2.
> 
> Unfortunately, this version has several bugs and 
> some bugs depend on each other.
> So, I collect, sort, and fold these patchs.
> 
> 
> btw: I wrote "this patch still crashed" last midnight.
> but it works well today.
> umm.. I was dreaming?

Yes.  I ran my stress load with Nishimura-san's cpuset migration test on
x86_64 and ia64 platforms overnight.  I didn't have all of the memcgroup
patches applied--just the unevictable lru related patches.  Tests ran
for ~19 hours--including 70k-80k passes through the cpuset migration
test--until I shut them down w/o error.  

OK, I did see two oom kills on the ia64.  My stress load was already
pretty close to edge, but they look suspect because I still had a couple
of MB free on each node according to the console logs.  The system did
seem to choose a reasonable task to kill, tho'--a memtoy test that locks
down 10s of GB of memory.

> 
> Anyway, I believe this patchset improve robustness and
> provide better testing baseline.
> 
> enjoy!

I'll restart the tests with this series.

> 
> 
> Andrew, this patchset is my silver-spoon.
> if you like it, I'm glad too.
> 
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

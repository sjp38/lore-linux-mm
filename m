Date: Sat, 23 Aug 2008 22:29:23 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC][PATCH 1/2] Show quicklist at meminfo
Message-Id: <20080823222923.9a7ce3d5.akpm@linux-foundation.org>
In-Reply-To: <20080823171352.2533.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20080822100049.F562.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	<20080821212847.f7fc936b.akpm@linux-foundation.org>
	<20080823171352.2533.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cl@linux-foundation.org, tokunaga.keiich@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Sat, 23 Aug 2008 17:24:31 +0900 KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> > > OK.
> > > I ran cpu hotplug/unplug coutinuous workload over 12H.
> > > then, system crash doesn't happend.
> > > 
> > > So, I believe my patch is cpu unplug safe.
> > 
> > err, which patch?
> > 
> > I presently have:
> > 
> > mm-show-quicklist-memory-usage-in-proc-meminfo.patch
> > mm-show-quicklist-memory-usage-in-proc-meminfo-fix.patch
> > mm-quicklist-shouldnt-be-proportional-to-number-of-cpus.patch
> > mm-quicklist-shouldnt-be-proportional-to-number-of-cpus-fix.patch
> > 
> > Is that what you have?
> > 
> > I'll consolidate them into two patches and will append them here.  Please check.
> 
> Andrew, Thank you for your attention.
> 
> I test on
> 
> mm-show-quicklist-memory-usage-in-proc-meminfo.patch
> mm-show-quicklist-memory-usage-in-proc-meminfo-fix.patch
> 
> and 
> 
> http://marc.info/?l=linux-mm&m=121931317407295&w=2 
> 
> 
> the above url's patch already checked sparc64 compilable by David.
> and I tested it.
> 
> So, if possible, Could you replace current quicklist-shouldnt-be-proportional
> patch to that?
> (of cource, current -mm patch also works well)
> 

OK, there's just too much potential for miscommunication and error here.

Please resend everything as a sequence-numbered, fully-changlelogged
signed-off patch series against current mainline.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Date: Sat, 15 Nov 2008 23:54:10 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH -mm] vmscan: bail out of page reclaim after
 swap_cluster_max pages
Message-Id: <20081115235410.2d2c76de.akpm@linux-foundation.org>
In-Reply-To: <20081116163915.F208.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <491D8CEC.5050106@redhat.com>
	<20081114091828.48fc4b67.akpm@linux-foundation.org>
	<20081116163915.F208.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 16 Nov 2008 16:43:10 +0900 (JST) KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> > > Of course, one thing we could do is exempt kswapd from this check.
> > > During light reclaim, kswapd does most of the eviction so scanning
> > > should remain balanced.  Having one process fall down to a lower
> > > priority level is also not a big problem.
> > > 
> > > As long as the direct reclaim processes do not also fall into the
> > > same trap, the situation should be manageable.
> > > 
> > > Does that sound reasonable to you?
> > 
> > I'll need to find some time to go dig through the changelogs.  
> 
> as far as I tried, git database doesn't have that changelogs.
> FWIW, I guess it is more old.
> 

git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/old-2.6-bkcvs.git
goes back to 2.5.20 (iirc).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

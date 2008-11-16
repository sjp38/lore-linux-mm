Date: Sun, 16 Nov 2008 00:02:44 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH -mm] vmscan: bail out of page reclaim after
 swap_cluster_max pages
Message-Id: <20081116000244.f4d3234a.akpm@linux-foundation.org>
In-Reply-To: <20081116165533.F20B.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20081116163915.F208.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	<20081115235410.2d2c76de.akpm@linux-foundation.org>
	<20081116165533.F20B.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 16 Nov 2008 16:56:15 +0900 (JST) KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> > > > I'll need to find some time to go dig through the changelogs.  
> > > 
> > > as far as I tried, git database doesn't have that changelogs.
> > > FWIW, I guess it is more old.
> > 
> > git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/old-2.6-bkcvs.git
> > goes back to 2.5.20 (iirc).

err, make that 2.5.0.

> Wow!
> I'll try it.
> 
> Thanks!!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

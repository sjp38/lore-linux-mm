Date: Sun, 16 Nov 2008 16:56:15 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH -mm] vmscan: bail out of page reclaim after swap_cluster_max pages
In-Reply-To: <20081115235410.2d2c76de.akpm@linux-foundation.org>
References: <20081116163915.F208.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20081115235410.2d2c76de.akpm@linux-foundation.org>
Message-Id: <20081116165533.F20B.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > > I'll need to find some time to go dig through the changelogs.  
> > 
> > as far as I tried, git database doesn't have that changelogs.
> > FWIW, I guess it is more old.
> 
> git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/old-2.6-bkcvs.git
> goes back to 2.5.20 (iirc).

Wow!
I'll try it.

Thanks!!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

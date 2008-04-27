Date: Sun, 27 Apr 2008 23:50:29 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [BUGFIX][PATCH] Fix usemap initialization v3
In-Reply-To: <4814D459.1020602@linux.vnet.ibm.com>
Message-ID: <Pine.LNX.4.64.0804272349450.16359@blonde.site>
References: <20080418161522.GB9147@csn.ul.ie> <48080706.50305@cn.fujitsu.com>
 <48080930.5090905@cn.fujitsu.com> <48080B86.7040200@cn.fujitsu.com>
 <20080418211214.299f91cd.kamezawa.hiroyu@jp.fujitsu.com>
 <21878461.1208539556838.kamezawa.hiroyu@jp.fujitsu.com>
 <20080421112048.78f0ec76.kamezawa.hiroyu@jp.fujitsu.com>
 <Pine.LNX.4.64.0804211250000.16476@blonde.site>
 <20080422104043.215c7dc4.kamezawa.hiroyu@jp.fujitsu.com>
 <20080423134621.6020dd83.kamezawa.hiroyu@jp.fujitsu.com>
 <20080427121817.03b432ca.akpm@linux-foundation.org> <4814D459.1020602@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Shi Weihua <shiwh@cn.fujitsu.com>, xemul@openvz.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 28 Apr 2008, Balbir Singh wrote:
> Andrew Morton wrote:
> > 
> > Do we think this is needed in 2.6.25.x?
> 
> My answer would be yes. Shi reproduced this problem with 2.6.25

Yes, that's my understanding too.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

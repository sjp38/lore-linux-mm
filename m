Date: Fri, 7 Nov 2008 12:45:20 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [RFC][PATCH] mm: the page of MIGRATE_RESERVE don't insert into
 pcp
In-Reply-To: <20081107112722.GE13786@csn.ul.ie>
Message-ID: <Pine.LNX.4.64.0811071244330.5387@quilx.com>
References: <20081106091431.0D2A.KOSAKI.MOTOHIRO@jp.fujitsu.com>
 <20081106164644.GA14012@csn.ul.ie> <20081107104224.1631057e.kamezawa.hiroyu@jp.fujitsu.com>
 <20081107104242.GC13786@csn.ul.ie> <20081107200251.15e9851a.kamezawa.hiroyu@jp.fujitsu.com>
 <20081107112722.GE13786@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 7 Nov 2008, Mel Gorman wrote:

> Oh, do you mean splitting the list instead of searching? This is how it was
> originally implement and shot down on the grounds it increased the size of
> a per-cpu structure.

The situation may be better with the cpu_alloc stuff. The big pcp array in
struct zone for all possible processors will be gone and thus the memory
requirements will be less.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

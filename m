Date: Mon, 30 Jun 2008 17:17:08 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC 5/5] Memory controller soft limit reclaim on contention
In-Reply-To: <48689527.7070403@linux.vnet.ibm.com>
References: <20080630165125.37E6.KOSAKI.MOTOHIRO@jp.fujitsu.com> <48689527.7070403@linux.vnet.ibm.com>
Message-Id: <20080630171608.37E9.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

> > yes, memcg used only one page.
> > but mem_cgroup_reclaim_on_contention() reclaim for generic alloc_pages(), instead for memcg.
> > we can't assume memcg usage.
> > isn't it?
> 
> Yes, but the reclaim is from memcg pages (memcg groups that are over their soft
> limit). I am not sure if I understand your point? If your claim is that we don't
> free up pages of at-least order (as desired by __alloc_pages_internal()), that
> is correct. We can ensure that we do a pass over memcg and generic zone LRU.

exactly.
Thank you.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

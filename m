Date: Fri, 4 Jul 2008 11:48:04 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Question: split-lur // Re: 2.6.26-rc8-mm1
Message-Id: <20080704114804.081a850a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080703020236.adaa51fa.akpm@linux-foundation.org>
References: <20080703020236.adaa51fa.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "riel@redhat.com" <riel@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

In split-lru, zone->prev_priority seems not to be used.
(just remembers....)
Is this obsolete parameter ? 

I'm sorry if I miss something.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

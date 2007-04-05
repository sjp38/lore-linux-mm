Date: Thu, 5 Apr 2007 15:43:50 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 08/12] mm: fixup possible deadlock
Message-Id: <20070405154350.0ea203ea.akpm@linux-foundation.org>
In-Reply-To: <20070405174319.617238739@programming.kicks-ass.net>
References: <20070405174209.498059336@programming.kicks-ass.net>
	<20070405174319.617238739@programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: root@programming.kicks-ass.net
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, miklos@szeredi.hu, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, a.p.zijlstra@chello.nl, nikita@clusterfs.com
List-ID: <linux-mm.kvack.org>

On Thu, 05 Apr 2007 19:42:17 +0200
root@programming.kicks-ass.net wrote:

> When the threshol is in the order of the per cpu inaccuracies we can
> deadlock by not receiveing the updated count,

That explanation is a bit, umm, terse.

> introduce a more expensive
> but more accurate stat read function to use on low thresholds.

Looks like percpu_counter_sum().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

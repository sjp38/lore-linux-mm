Date: Sat, 21 Apr 2007 02:55:21 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 07/10] mm: count reclaimable pages per BDI
Message-Id: <20070421025521.8d77072e.akpm@linux-foundation.org>
In-Reply-To: <20070420155503.222304356@chello.nl>
References: <20070420155154.898600123@chello.nl>
	<20070420155503.222304356@chello.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, miklos@szeredi.hu, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com
List-ID: <linux-mm.kvack.org>

On Fri, 20 Apr 2007 17:52:01 +0200 Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:

> Count per BDI reclaimable pages; nr_reclaimable = nr_dirty + nr_unstable.

hm.  Aggregating dirty and unstable at inc/dec time is a bit kludgy.  If
later on we want to know just "dirty" then we're in trouble.

I can see the logic behind it though.

Perhaps one could have separate BDI_DIRTY and BDI_UNSTABLE and treat them
separately at inc/dec time, but give them the same numerical value, so
they in fact refer to the same counter.  That's kludgy too.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

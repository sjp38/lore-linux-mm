Date: Thu, 5 Apr 2007 15:44:40 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 09/12] mm: remove throttle_vm_writeback
Message-Id: <20070405154440.0f42fa9f.akpm@linux-foundation.org>
In-Reply-To: <20070405174319.860268120@programming.kicks-ass.net>
References: <20070405174209.498059336@programming.kicks-ass.net>
	<20070405174319.860268120@programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: root@programming.kicks-ass.net
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, miklos@szeredi.hu, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, a.p.zijlstra@chello.nl, nikita@clusterfs.com
List-ID: <linux-mm.kvack.org>

On Thu, 05 Apr 2007 19:42:18 +0200
root@programming.kicks-ass.net wrote:

> rely on accurate dirty page accounting to provide enough push back

I think we'd like to see a bit more justification than that, please.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

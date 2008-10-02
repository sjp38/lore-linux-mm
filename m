Date: Thu, 2 Oct 2008 12:47:48 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 00/32] Swap over NFS - v19
Message-Id: <20081002124748.638c95ff.akpm@linux-foundation.org>
In-Reply-To: <20081002130504.927878499@chello.nl>
References: <20081002130504.927878499@chello.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no, Daniel Lezcano <dlezcano@fr.ibm.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Neil Brown <neilb@suse.de>, David Miller <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>

On Thu, 02 Oct 2008 15:05:04 +0200 Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:

> Let's get this ball rolling...

I don't think we're really able to get any MM balls rolling until we
get all the split-LRU stuff landed.  Is anyone testing it?  Is it good?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

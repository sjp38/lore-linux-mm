Subject: Re: [PATCH 00/32] Swap over NFS - v19
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20081002124748.638c95ff.akpm@linux-foundation.org>
References: <20081002130504.927878499@chello.nl>
	 <20081002124748.638c95ff.akpm@linux-foundation.org>
Content-Type: text/plain
Date: Thu, 02 Oct 2008 16:59:09 -0400
Message-Id: <1222981149.6129.136.camel@lts-notebook>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no, Daniel Lezcano <dlezcano@fr.ibm.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Neil Brown <neilb@suse.de>, David Miller <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>

On Thu, 2008-10-02 at 12:47 -0700, Andrew Morton wrote:
> On Thu, 02 Oct 2008 15:05:04 +0200 Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
> 
> > Let's get this ball rolling...
> 
> I don't think we're really able to get any MM balls rolling until we
> get all the split-LRU stuff landed.  Is anyone testing it?  Is it good?

Andrew:

Up until the mailing list traffic and patches slowed down, I was testing
it continuously with a heavy stress load that would bring the system to
its knees before the splitlru and unevictable changes.  When it would
run for days without error [96 hours was my max run] and no further
patches came, I've concentrated on other things.

Rik and Kosaki-san have run some performance oriented tests, reported
here a while back.  Maybe they have more info.

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

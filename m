Date: Tue, 06 May 2003 07:20:51 -0700 (PDT)
Message-Id: <20030506.072051.45141886.davem@redhat.com>
Subject: Re: 2.5.69-mm1
From: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030506152555.GC9875@in.ibm.com>
References: <20030506110907.GB9875@in.ibm.com>
	<1052222542.983.27.camel@rth.ninka.net>
	<20030506152555.GC9875@in.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: dipankar@in.ibm.com
Cc: wli@holomorphy.com, akpm@digeo.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

   On Tue, May 06, 2003 at 05:02:22AM -0700, David S. Miller wrote:
   > rwlocks believe it or not tend not to be superior over spinlocks,
   > they actually promote cache line thrashing in the case they
   > are actually being effective (>1 parallel reader)
   
   Provided there isn't a very heavy contention among readers for the
   spin_lock.

Even if there are thousands of readers trying to get the lock
at the same time, unless your hold time is significant these
readers will merely thrash the cache getting the rwlock_t.
And then thrash it again to release the rwlock_t.

This is especially true if the spinlock lives in the same cache
lines as the data it protects.

All of this is magnified on NUMA.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

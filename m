Date: Tue, 6 May 2003 21:17:55 +0530
From: Dipankar Sarma <dipankar@in.ibm.com>
Subject: Re: 2.5.69-mm1
Message-ID: <20030506154755.GD9875@in.ibm.com>
Reply-To: dipankar@in.ibm.com
References: <20030506110907.GB9875@in.ibm.com> <1052222542.983.27.camel@rth.ninka.net> <20030506152555.GC9875@in.ibm.com> <20030506.072051.45141886.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030506.072051.45141886.davem@redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "David S. Miller" <davem@redhat.com>
Cc: wli@holomorphy.com, akpm@digeo.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 06, 2003 at 07:20:51AM -0700, David S. Miller wrote:
>    From: Dipankar Sarma <dipankar@in.ibm.com>
>    
>    Provided there isn't a very heavy contention among readers for the
>    spin_lock.
> 
> Even if there are thousands of readers trying to get the lock
> at the same time, unless your hold time is significant these
> readers will merely thrash the cache getting the rwlock_t.
> And then thrash it again to release the rwlock_t.

And now ISTR that this is indeed the case, atleast going by
what we saw with "chat" microbenchmarks (fwiw :)).
Hold times weren't very high and most of the performance penalty
came from bouncing of the rwlock cacheline, which prompted us to
write a RCU-based patch for lockfree lookup from fd table.

Thanks
Dipankar
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

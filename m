Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 9108F6B0069
	for <linux-mm@kvack.org>; Wed, 22 Aug 2012 06:54:02 -0400 (EDT)
Date: Wed, 22 Aug 2012 11:48:06 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [MMTests] dbench4 async on ext3
Message-ID: <20120822104806.GD15058@suse.de>
References: <20120620113252.GE4011@suse.de>
 <20120629111932.GA14154@suse.de>
 <20120723212146.GG9222@suse.de>
 <20120821220038.GA19171@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20120821220038.GA19171@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org

On Wed, Aug 22, 2012 at 12:00:38AM +0200, Jan Kara wrote:
> On Mon 23-07-12 22:21:46, Mel Gorman wrote:
> > Configuration:	global-dhp__io-dbench4-async-ext3
> > Result: 	http://www.csn.ul.ie/~mel/postings/mmtests-20120424/global-dhp__io-dbench4-async-ext3
> > Benchmarks:	dbench4
> > 
> > Summary
> > =======
> > 
> > In general there was a massive drop in throughput after 3.0. Very broadly
> > speaking it looks like the Read operation got faster but at the cost of
> > a big regression in the Flush operation.
>
>   Mel, I had a look into this and it's actually very likely only a
> configuration issue. In 3.1 ext3 started to default to enabled barriers
> (barrier=1 in mount options) which is a safer but slower choice. When I set
> barriers explicitely, I see no performance difference for dbench4 between
> 3.0 and 3.1.
> 

I've confirmed that disabling barriers fixed it, for one test machine and
one test at least. I'll reschedule the tests to run with barriers disabled
at some point in the future. Thanks for tracking it down, I was at least
two weeks away before I got the chance to even look.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

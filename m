Date: Tue, 18 Sep 2007 23:00:59 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [PATCH 1/1] cpusets/sched_domain reconciliation
Message-Id: <20070918230059.f3b39250.pj@sgi.com>
In-Reply-To: <20070913154607.9c49e1c7.akpm@linux-foundation.org>
References: <20070907210704.E6BE02FC059@attica.americas.sgi.com>
	<20070913154607.9c49e1c7.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: cpw@sgi.com, linux-mm@kvack.org, nickpiggin@yahoo.com.au, mingo@elte.hu
List-ID: <linux-mm.kvack.org>

Andrew replied to Cliff a few days ago:
> I suspect your change is fundamentally incompatible with, and perhaps
> obsoleted by ... cpuset-remove-sched-domain-hooks-from-cpusets.patch

I suspect the same thing.

> Problem is, cpuset-remove-sched-domain-hooks-from-cpusets.patch has been
> hanging around in -mm for a year while Paul makes up his mind about it.
> 
> Can we please get all this sorted out??

I'll see what I can do.  Cpuset support seems to have finally gotten
back to the front of my queue.

Sorry for the absurdly long hiatus.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

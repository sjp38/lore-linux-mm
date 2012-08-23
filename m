Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id ADAE46B005A
	for <linux-mm@kvack.org>; Thu, 23 Aug 2012 12:07:03 -0400 (EDT)
Date: Thu, 23 Aug 2012 13:06:48 -0300
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [PATCH v8 1/5] mm: introduce a common interface for balloon
 pages mobility
Message-ID: <20120823160647.GA10777@t510.redhat.com>
References: <20120822093317.GC10680@redhat.com>
 <20120823021903.GA23660@x61.redhat.com>
 <20120823100107.GA17409@redhat.com>
 <20120823121338.GA3062@t510.redhat.com>
 <20120823123432.GA25659@redhat.com>
 <20120823130606.GB3746@t510.redhat.com>
 <20120823135328.GB25709@redhat.com>
 <20120823152128.GA8975@t510.redhat.com>
 <20120823155401.GA28876@redhat.com>
 <50365443.1070104@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50365443.1070104@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: "Michael S. Tsirkin" <mst@redhat.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Peter Zijlstra <peterz@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Minchan Kim <minchan@kernel.org>

On Thu, Aug 23, 2012 at 12:03:15PM -0400, Rik van Riel wrote:
> >
> >Not "longer" - apparently forever unless user resend the leak command.
> >It's wrong - it should
> >1. not tell host if nothing was done
> >2. after migration finished leak and tell host
> 
> Agreed.  If the balloon is told to leak N pages, and could
> not do so because those pages were locked, the balloon driver
> needs to retry (maybe waiting on a page lock?) and not signal
> completion until after the job has been completed.
> 
> Having the balloon driver wait on the page lock should be
> fine, because compaction does not hold the page lock for
> long.

And that is precisely what leak_balloon is doing. When it stumbles across a
locked page it gets rid of that leak round to give a shot for compaction to
finish its task.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

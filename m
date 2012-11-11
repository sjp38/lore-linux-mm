Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 116A86B002B
	for <linux-mm@kvack.org>; Sun, 11 Nov 2012 14:22:30 -0500 (EST)
Date: Sun, 11 Nov 2012 17:22:07 -0200
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [PATCH v11 7/7] mm: add vm event counters for balloon pages
 compaction
Message-ID: <20121111192206.GB4290@x61.redhat.com>
References: <cover.1352256081.git.aquini@redhat.com>
 <8dde7996f3e36a5efbe569afe1aadfc84355e79e.1352256088.git.aquini@redhat.com>
 <20121110155538.GC13846@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121110155538.GC13846@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Minchan Kim <minchan@kernel.org>, Peter Zijlstra <peterz@infradead.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On Sat, Nov 10, 2012 at 05:55:38PM +0200, Michael S. Tsirkin wrote:
> >  	mutex_unlock(&vb->balloon_lock);
> > +	balloon_event_count(COMPACTBALLOONMIGRATED);
> >  
> >  	return MIGRATEPAGE_BALLOON_SUCCESS;
> >  }
> 
> Looks like any ballon would need to do this.
> Can this  chunk go into caller instead?
>

Good catch. It's done, already (v12 just hit the wild).

Thanks!
-- Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

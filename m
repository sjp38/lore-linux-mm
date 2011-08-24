Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id C73926B0169
	for <linux-mm@kvack.org>; Wed, 24 Aug 2011 02:17:46 -0400 (EDT)
Date: Wed, 24 Aug 2011 02:17:43 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 04/13] mm: new shrinker API
Message-ID: <20110824061743.GC24077@infradead.org>
References: <1314089786-20535-1-git-send-email-david@fromorbit.com>
 <1314089786-20535-5-git-send-email-david@fromorbit.com>
 <20110823091529.GC21492@infradead.org>
 <20110823092330.GY3162@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110823092330.GY3162@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, khlebnikov@openvz.org

On Tue, Aug 23, 2011 at 07:23:30PM +1000, Dave Chinner wrote:
> > It's much more than just a single callback these days.
> > 
> > > + * @scan_objects will be made from the current reclaim context.
> > >   */
> > >  struct shrinker {
> > >  	int (*shrink)(struct shrinker *, struct shrink_control *sc);
> > > +	long (*count_objects)(struct shrinker *, struct shrink_control *sc);
> > > +	long (*scan_objects)(struct shrinker *, struct shrink_control *sc);
> > 
> > Is shrink_object really such a good name for this method?
> 
> Apart from the fact it is called "scan_objects", I'm open to more
> appropriate names. I called is "scan_objects" because of the fact we
> are asking to scan (rather than free) a specific number objects on
> the LRU, and it matches with the "sc->nr_to_scan" control field.

Shrink_objects actually was my suggestion - while we are asked to scan
the objects the scan really isn't the main purpose of it.  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Date: Wed, 19 Mar 2008 10:49:59 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 2/9] Store max number of objects in the page struct.
In-Reply-To: <1205917757.10318.1.camel@ymzhang>
Message-ID: <Pine.LNX.4.64.0803191049450.29173@schroedinger.engr.sgi.com>
References: <20080317230516.078358225@sgi.com>  <20080317230528.279983034@sgi.com>
 <1205917757.10318.1.camel@ymzhang>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Mel Gorman <mel@csn.ul.ie>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 19 Mar 2008, Zhang, Yanmin wrote:

> > +	if ((PAGE_SIZE << min_order) / size > 65535)
> > +		return get_order(size * 65535) - 1;
> Is it better to define something like USHORT_MAX to replace 65535?

Yes. Do we have something like that?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

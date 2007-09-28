Date: Fri, 28 Sep 2007 11:38:10 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [PATCH 5/6] Filter based on a nodemask as well as a gfp_mask
Message-Id: <20070928113810.9a5cbaf2.pj@sgi.com>
In-Reply-To: <20070928182825.GA9779@skynet.ie>
References: <20070928142326.16783.98817.sendpatchset@skynet.skynet.ie>
	<20070928142506.16783.99266.sendpatchset@skynet.skynet.ie>
	<1190993823.5513.10.camel@localhost>
	<20070928182825.GA9779@skynet.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: Lee.Schermerhorn@hp.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, rientjes@google.com, kamezawa.hiroyu@jp.fujitsu.com, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

Mel replied to Lee:
> > > +	return nodes_intersect(nodemask, current->mems_allowed);
> >                  ^^^^^^^^^^^^^^^ -- should be nodes_intersects, I think.
> 
> Crap, you're right, I missed the warning about implicit declarations. I
> apologise. This is the corrected version

I found myself making that same error, saying 'nodes_intersect' instead
of 'nodes_intersects' the other day.  And I might be the one who invented
that name ;).

This would probably be too noisey and too little gain to do on the
Linux kernel, but if this was just a little private project of my own,
I'd be running a script over the whole thing, modifying all 30 or so
instances of bitmap_intersects, cpus_intersects and nodes_intersects so
as to remove the final 's' character.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

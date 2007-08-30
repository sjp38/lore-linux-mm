Subject: Re: RFC:  Noreclaim with "Keep Mlocked Pages off the LRU"
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <46D60AA9.3070309@redhat.com>
References: <20070823041137.GH18788@wotan.suse.de>
	 <1187988218.5869.64.camel@localhost> <20070827013525.GA23894@wotan.suse.de>
	 <1188225247.5952.41.camel@localhost> <20070828000648.GB14109@wotan.suse.de>
	 <1188312766.5079.77.camel@localhost>
	 <Pine.LNX.4.64.0708281448440.17464@schroedinger.engr.sgi.com>
	 <1188398451.5121.9.camel@localhost>
	 <Pine.LNX.4.64.0708291035080.21184@schroedinger.engr.sgi.com>
	 <46D60AA9.3070309@redhat.com>
Content-Type: text/plain
Date: Thu, 30 Aug 2007 10:49:00 -0400
Message-Id: <1188485340.5794.29.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Christoph Lameter <clameter@sgi.com>, Nick Piggin <npiggin@suse.de>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2007-08-29 at 20:09 -0400, Rik van Riel wrote:
> Christoph Lameter wrote:
> > On Wed, 29 Aug 2007, Lee Schermerhorn wrote:
> > 
> >>> I think that is the right approach. Do not forget that ramfs and other 
> >>> ram based filesystems create unmapped unreclaimable pages.
> >> They don't go on the LRU lists now, do they?  The primary function of
> >> the noreclaim infrastructure is to hide non-reclaimable pages that would
> >> otherwise go on the [in]active lists from vmscan.  So, if pages used by
> >> the ram base file systems don't go onto the LRU, we probably don't need
> >> to put them on the noreclaim list which is conceptually another LRU
> >> list.
> > 
> > They do go into the LRU. When attempts are made to write them out they are 
> > put back onto the active lists via a strange return code 
> > AOP_WRITEPAGE_ACTIVATE. So they circle round and round and round...
> > 
> >>> Right. I posted a patch a week ago that generalized LRU handling and would 
> >>> allow the adding of additional lists as needed by such an approach.
> >> Which one was that? 
> > 
> > This one
> > 
> > [RECLAIM] Use an indexed array for active/inactive variables
> > 
> > Currently we are defining explicit variables for the inactive and active
> > list. An indexed array can be more generic and avoid repeating similar
> > code in several places in the reclaim code.
> 
> I like it.  This will make the code that has separate lists
> for anonymous (and other swap backed) pages a lot nicer.

Ditto.

I'll incorporate it into the noreclaim set and into the copy of Rik's
split lru patch that I'm maintaining.  Should make it easier to merge
the two sets.

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Date: Thu, 5 Apr 2007 05:57:41 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [RFC] Free up page->private for compound pages
Message-ID: <20070405035741.GH11192@wotan.suse.de>
References: <Pine.LNX.4.64.0704042016490.7885@schroedinger.engr.sgi.com> <20070405033648.GG11192@wotan.suse.de> <Pine.LNX.4.64.0704042037550.8745@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0704042037550.8745@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, dgc@sgi.com
List-ID: <linux-mm.kvack.org>

On Wed, Apr 04, 2007 at 08:38:52PM -0700, Christoph Lameter wrote:
> On Thu, 5 Apr 2007, Nick Piggin wrote:
> 
> > On Wed, Apr 04, 2007 at 08:19:22PM -0700, Christoph Lameter wrote:
> > > If we add a new flag so that we can distinguish between the
> > > first page and the tail pages then we can avoid to use page->private
> > > in the first page of a compound page. page->private == page for the first 
> > > page, so there is no real information in there.
> > 
> > Couldn't you use something like PageActive for the head page instead of
> > taking up a new flag, seeing as we don't put compound pages on the LRU?
> 
> We could set up an alias for now?

Yeah, definitely use an alias.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

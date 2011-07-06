Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 9D7689000C2
	for <linux-mm@kvack.org>; Tue,  5 Jul 2011 23:38:45 -0400 (EDT)
Date: Tue, 5 Jul 2011 20:30:12 -0700
From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH v2] staging: zcache: support multiple clients, prep for
 KVM and RAMster
Message-ID: <20110706033012.GA15581@kroah.com>
References: <1d15f28a-56df-4cf4-9dd9-1032f211c0d0@default20110630224019.GC2544@shale.localdomain>
 <3b67511f-bad9-4c41-915b-1f6e196f4d43@default20110701083850.GE2544@shale.localdomain>
 <871d7dbc-041f-411f-b91a-cbc5aeb9db98@default>
 <20110701165845.GG2544@shale.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110701165845.GG2544@shale.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Carpenter <error27@gmail.com>
Cc: Dan Magenheimer <dan.magenheimer@oracle.com>, Greg Kroah-Hartman <gregkh@suse.de>, Marcus Klemm <marcus.klemm@googlemail.com>, kvm@vger.kernel.org, Konrad Wilk <konrad.wilk@oracle.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, devel@linuxdriverproject.org

On Fri, Jul 01, 2011 at 07:58:45PM +0300, Dan Carpenter wrote:
> On Fri, Jul 01, 2011 at 07:31:54AM -0700, Dan Magenheimer wrote:
> > > Off by one errors are kind of insidious.  People cut and paste them
> > > and they spread.  If someone adds a new list of chunks then there
> > > are now two examples that are correct and two which have an extra
> > > element, so it's 50/50 that he'll copy the right one.
> > 
> > True, but these are NOT off-by-one errors... they are
> > correct-but-slightly-ugly code snippets.  (To clarify, I said
> > the *ugliness* arose when debugging an off-by-one error.)
> > 
> 
> What I meant was the new arrays are *one* element too large.
> 
> > Patches always welcome, and I agree that these should be
> > fixed eventually, assuming the code doesn't go away completely
> > first.. I'm simply stating the position
> > that going through another test/submit cycling to fix
> > correct-but-slightly-ugly code which is present only to
> > surface information for experiments is not high on my priority
> > list right now... unless GregKH says he won't accept the patch.
> >  
> > > Btw, looking at it again, this seems like maybe a similar issue in
> > > zbud_evict_zbpg():
> > > 
> > >    516          for (i = 0; i < MAX_CHUNK; i++) {
> > >    517  retry_unbud_list_i:
> > > 
> > > 
> > > MAX_CHUNKS is NCHUNKS - 1.  Shouldn't that be i < NCHUNKS so that we
> > > reach the last element in the list?
> > 
> > No, the last element in that list is unused.  There is a comment
> > to that effect someplace in the code.  (These lists are keeping
> > track of pages with "chunks" of available space and the last
> > entry would have no available space so is always empty.)
> 
> The comment says that the first element isn't used.  Perhaps the
> comment is out of date and now it's the last element that isn't
> used.  To me, it makes sense to have an unused first element, but it
> doesn't make sense to have an unused last element.  Why not just
> make the array smaller?
> 
> Also if the last element of the original arrays isn't used, then
> does that mean the last *two* elements of the new arrays aren't
> used?
> 
> Getting array sizes wrong is not a "correct-but-slightly-ugly"
> thing.  *grumble* *grumble* *grumble*.  But it doesn't crash the
> system so I'm fine with it going in as is...

I'm not.  Please fix this up.  I'll not accept it until it is.

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

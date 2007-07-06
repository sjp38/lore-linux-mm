Date: Fri, 6 Jul 2007 20:01:10 +1000
From: David Chinner <dgc@sgi.com>
Subject: Re: vm/fs meetup details
Message-ID: <20070706100110.GD12413810@sgi.com>
References: <20070705040138.GG32240@wotan.suse.de> <468D303E.4040902@redhat.com> <137D15F6-EABE-4EC1-A3AF-DAB0A22CF4E3@oracle.com> <20070705212757.GB12413810@sgi.com> <468D6569.6050606@redhat.com> <20070706022651.GG14215@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070706022651.GG14215@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Rik van Riel <riel@redhat.com>, David Chinner <dgc@sgi.com>, Zach Brown <zach.brown@oracle.com>, Anton Altaparmakov <aia21@cam.ac.uk>, Suparna Bhattacharya <suparna@in.ibm.com>, Christoph Hellwig <hch@infradead.org>, Hugh Dickins <hugh@veritas.com>, Jared Hulbert <jaredeh@gmail.com>, Chris Mason <chris.mason@oracle.com>, "Martin J. Bligh" <mbligh@mbligh.org>, Trond Myklebust <trond.myklebust@fys.uio.no>, Neil Brown <neilb@suse.de>, Joern Engel <joern@logfs.org>, Miklos Szeredi <miklos@szeredi.hu>, Mingming Cao <cmm@us.ibm.com>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, Evgeniy Polyakov <johnpol@2ka.mipt.ru>, Steven Whitehouse <steve@chygwyn.com>, Dave McCracken <dave.mccracken@oracle.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

On Fri, Jul 06, 2007 at 04:26:51AM +0200, Nick Piggin wrote:
> On Thu, Jul 05, 2007 at 05:40:57PM -0400, Rik van Riel wrote:
> > David Chinner wrote:
> > >On Thu, Jul 05, 2007 at 01:40:08PM -0700, Zach Brown wrote:
> > >>>- repair driven design, we know what it is (Val told us), but
> > >>> how does it apply to the things we are currently working on?
> > >>> should we do more of it?
> > >>I'm sure Chris and I could talk about the design elements in btrfs  
> > >>that should aid repair if folks are interested in hearing about  
> > >>them.  We'd keep the hand-waving to a minimum :).
> > >
> > >And I'm sure I could provide a counterpoint by talking about
> > >the techniques we've used improving XFS repair speed and
> > >scalability without needing to change any on disk formats....
> > 
> > Sounds like that could be an interesting discussion.
> > 
> > Especially when trying to answer questions like:
> > 
> > "At what filesystem size will the mitigating fixes no
> >  longer be enough?"
> > 
> > and
> > 
> > "When will people start using filesystems THAT big?"  :)
> 
> Keep in mind that the way to get the most out of this meeting
> is for the fs people to have topics of the form "we'd really
> like to do X, can we get some help from the VM"? Or vice versa
> from vm people.

*nod*

But, surprisingly enough, the above work is relevent to this forum
because of two things:

	- we've had to move to direct I/O and user space caching to
	  work around deficiencies in kernel block device caching
	  under memory pressure....

	- we've exploited techniques that XFS supports but the VM
	  does not. i.e. priority tagging of cached metadata so that
	  less important metadata is tossed first (e.g. toss tree
	  leaves before nodes and nodes before roots) when under
	  memory pressure.


> That said, we can talk about whatever interests the group on
> the day. And that could definitely include issues common to
> different filesystems.

Sure ;)

Cheers,

Dave.
-- 
Dave Chinner
Principal Engineer
SGI Australian Software Group

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

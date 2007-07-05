Date: Fri, 6 Jul 2007 07:27:57 +1000
From: David Chinner <dgc@sgi.com>
Subject: Re: vm/fs meetup details
Message-ID: <20070705212757.GB12413810@sgi.com>
References: <20070705040138.GG32240@wotan.suse.de> <468D303E.4040902@redhat.com> <137D15F6-EABE-4EC1-A3AF-DAB0A22CF4E3@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <137D15F6-EABE-4EC1-A3AF-DAB0A22CF4E3@oracle.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Zach Brown <zach.brown@oracle.com>
Cc: Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Anton Altaparmakov <aia21@cam.ac.uk>, Suparna Bhattacharya <suparna@in.ibm.com>, Christoph Hellwig <hch@infradead.org>, Hugh Dickins <hugh@veritas.com>, Jared Hulbert <jaredeh@gmail.com>, Chris Mason <chris.mason@oracle.com>, David Chinner <dgc@sgi.com>, "Martin J. Bligh" <mbligh@mbligh.org>, Trond Myklebust <trond.myklebust@fys.uio.no>, Neil Brown <neilb@suse.de>, Joern Engel <joern@logfs.org>, Miklos Szeredi <miklos@szeredi.hu>, Mingming Cao <cmm@us.ibm.com>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 05, 2007 at 01:40:08PM -0700, Zach Brown wrote:
> >- repair driven design, we know what it is (Val told us), but
> >  how does it apply to the things we are currently working on?
> >  should we do more of it?
> 
> I'm sure Chris and I could talk about the design elements in btrfs  
> that should aid repair if folks are interested in hearing about  
> them.  We'd keep the hand-waving to a minimum :).

And I'm sure I could provide a counterpoint by talking about
the techniques we've used improving XFS repair speed and
scalability without needing to change any on disk formats....

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

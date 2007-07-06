From: Neil Brown <neilb@suse.de>
Date: Sat, 7 Jul 2007 09:47:11 +1000
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Message-ID: <18062.54399.299212.286138@notabene.brown>
Subject: Re: vm/fs meetup details
In-Reply-To: message from Steven Whitehouse on Friday July 6
References: <468D303E.4040902@redhat.com>
	<137D15F6-EABE-4EC1-A3AF-DAB0A22CF4E3@oracle.com>
	<20070705212757.GB12413810@sgi.com>
	<468D6569.6050606@redhat.com>
	<20070706022651.GG14215@wotan.suse.de>
	<20070706100110.GD12413810@sgi.com>
	<20070706102623.GA846@lazybastard.org>
	<20070706134201.GL31489@sgi.com>
	<20070706095214.1ac9da94@think.oraclecorp.com>
	<20070706155748.GC846@lazybastard.org>
	<20070706155803.GA31405@fogou.chygwyn.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Steven Whitehouse <steve@chygwyn.com>
Cc: =?iso-8859-1?Q?J=F6rn?= Engel <joern@logfs.org>, Chris Mason <chris.mason@oracle.com>, David Chinner <dgc@sgi.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Zach Brown <zach.brown@oracle.com>, Anton Altaparmakov <aia21@cam.ac.uk>, Suparna Bhattacharya <suparna@in.ibm.com>, Christoph Hellwig <hch@infradead.org>, Hugh Dickins <hugh@veritas.com>, Jared Hulbert <jaredeh@gmail.com>, "Martin J. Bligh" <mbligh@mbligh.org>, Trond Myklebust <trond.myklebust@fys.uio.no>, Miklos Szeredi <miklos@szeredi.hu>, Mingming Cao <cmm@us.ibm.com>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, Evgeniy Polyakov <johnpol@2ka.mipt.ru>, Dave McCracken <dave.mccracken@oracle.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

On Friday July 6, steve@chygwyn.com wrote:
> Hi,
> 
> On Fri, Jul 06, 2007 at 05:57:49PM +0200, Jorn Engel wrote:
...
> > 
> > Interesting idea.  Is it possible to attach several address spaces to an
> > inode?  That would cure some headaches.
> >
> GFS2 already uses something like this, in fact by having a second inode
> to contain the second address space. Thats a bit of a hack but we can't
...
> 
> So that would certainly be an issue that I'd like to discuss to see
> what can be worked out in that area,
> 
> Steve.

Maybe the question here is:

  What support should common code provide for caching indexing
  metadata?

Common code already provides the page cache that is very nice for
caching file data.
Some filesystems use the blockdev page cache to cache index metadata
by physical address.  But I think that increasingly filesystems want
to cache index metadata by some sort of virtual address.
A second page cache address space would be suitable if the addresses
were dense, and would be acceptable if the blocks were page-sized (or
larger).  But for non-dense, non-page-sized blocks, a radix tree of
pages is less than ideal (I think).

My filesystem (LaFS, which is actually beginning to work thanks to
Novell's HackWeek) uses non-dense, non-page-sized blocks both for file
indexing and for directories and while I have a working solution for
each case, there is room for improvements that might fit well with
other filesystems too.

NeilBrown

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

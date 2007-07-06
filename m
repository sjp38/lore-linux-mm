Date: Fri, 6 Jul 2007 16:58:03 +0100
From: Steven Whitehouse <steve@chygwyn.com>
Subject: Re: vm/fs meetup details
Message-ID: <20070706155803.GA31405@fogou.chygwyn.com>
References: <468D303E.4040902@redhat.com> <137D15F6-EABE-4EC1-A3AF-DAB0A22CF4E3@oracle.com> <20070705212757.GB12413810@sgi.com> <468D6569.6050606@redhat.com> <20070706022651.GG14215@wotan.suse.de> <20070706100110.GD12413810@sgi.com> <20070706102623.GA846@lazybastard.org> <20070706134201.GL31489@sgi.com> <20070706095214.1ac9da94@think.oraclecorp.com> <20070706155748.GC846@lazybastard.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20070706155748.GC846@lazybastard.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: =?iso-8859-1?Q?J=F6rn?= Engel <joern@logfs.org>
Cc: Chris Mason <chris.mason@oracle.com>, David Chinner <dgc@sgi.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Zach Brown <zach.brown@oracle.com>, Anton Altaparmakov <aia21@cam.ac.uk>, Suparna Bhattacharya <suparna@in.ibm.com>, Christoph Hellwig <hch@infradead.org>, Hugh Dickins <hugh@veritas.com>, Jared Hulbert <jaredeh@gmail.com>, "Martin J. Bligh" <mbligh@mbligh.org>, Trond Myklebust <trond.myklebust@fys.uio.no>, Neil Brown <neilb@suse.de>, Miklos Szeredi <miklos@szeredi.hu>, Mingming Cao <cmm@us.ibm.com>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, Evgeniy Polyakov <johnpol@2ka.mipt.ru>, Dave McCracken <dave.mccracken@oracle.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

Hi,

On Fri, Jul 06, 2007 at 05:57:49PM +0200, Jorn Engel wrote:
> On Fri, 6 July 2007 09:52:14 -0400, Chris Mason wrote:
> > On Fri, 6 Jul 2007 23:42:01 +1000 David Chinner <dgc@sgi.com> wrote:
> > 
> > > Hmmm - I guess you could use it for writeback ordering. I hadn't
> > > really thought about that. Doesn't seem a particularly efficient way
> > > of doing it, though. Why not just use multiple address spaces for
> > > this? i.e. one per level and flush in ascending order.
> 
> Interesting idea.  Is it possible to attach several address spaces to an
> inode?  That would cure some headaches.
>
GFS2 already uses something like this, in fact by having a second inode
to contain the second address space. Thats a bit of a hack but we can't
put the second address space into the inode since that causes problems
during writeback of inodes. So our perferred solution would be to put
the second address space into the glock structure, but we can't do that
until some of the VFS/VM routines can cope with mapping->host not being
an inode.

So that would certainly be an issue that I'd like to discuss to see
what can be worked out in that area,

Steve.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

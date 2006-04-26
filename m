Date: Wed, 26 Apr 2006 13:31:14 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Lockless page cache test results
In-Reply-To: <20060426184945.GL5002@suse.de>
Message-ID: <Pine.LNX.4.64.0604261330310.20897@schroedinger.engr.sgi.com>
References: <20060426135310.GB5083@suse.de> <20060426095511.0cc7a3f9.akpm@osdl.org>
 <20060426174235.GC5002@suse.de> <20060426111054.2b4f1736.akpm@osdl.org>
 <Pine.LNX.4.64.0604261130450.19587@schroedinger.engr.sgi.com>
 <20060426114737.239806a2.akpm@osdl.org> <20060426184945.GL5002@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: dgc@sgi.com
Cc: Jens Axboe <axboe@suse.de>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, npiggin@suse.de, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

have seen?

On Wed, 26 Apr 2006, Jens Axboe wrote:

> On Wed, Apr 26 2006, Andrew Morton wrote:
> > Christoph Lameter <clameter@sgi.com> wrote:
> > >
> > > On Wed, 26 Apr 2006, Andrew Morton wrote:
> > > 
> > > > OK.  That doesn't sound like something which a real application is likely
> > > > to do ;)
> > > 
> > > A real application scenario may be an application that has lots of threads 
> > > that are streaming data through multiple different disk channels (that 
> > > are able to transfer data simultanouesly. e.g. connected to different 
> > > nodes in a NUMA system) into the same address space.
> > > 
> > > Something like the above is fairly typical for multimedia filters 
> > > processing large amounts of data.
> > 
> > >From the same file?
> > 
> > To /dev/null?
> 
> /dev/null doesn't have much to do with it, other than the fact that it
> basically stresses only the input side of things. Same file is the
> interesting bit of course, as that's the the granularity of the
> tree_lock.
> 
> I haven't tested much else, I'll ask the tool to bench more files :)
> 
> -- 
> Jens Axboe
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Date: Thu, 1 Nov 2007 11:51:03 -0400
From: Chris Mason <chris.mason@oracle.com>
Subject: Re: migratepage failures on reiserfs
Message-ID: <20071101115103.62de4b2e@think.oraclecorp.com>
In-Reply-To: <1193935137.26106.5.camel@dyn9047017100.beaverton.ibm.com>
References: <1193768824.8904.11.camel@dyn9047017100.beaverton.ibm.com>
	<20071030135442.5d33c61c@think.oraclecorp.com>
	<1193781245.8904.28.camel@dyn9047017100.beaverton.ibm.com>
	<20071030185840.48f5a10b@think.oraclecorp.com>
	<1193847261.17412.13.camel@dyn9047017100.beaverton.ibm.com>
	<20071031134006.2ecd520b@think.oraclecorp.com>
	<1193935137.26106.5.camel@dyn9047017100.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: reiserfs-devel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, 01 Nov 2007 08:38:57 -0800
Badari Pulavarty <pbadari@us.ibm.com> wrote:

> On Wed, 2007-10-31 at 13:40 -0400, Chris Mason wrote:
> > On Wed, 31 Oct 2007 08:14:21 -0800
> > Badari Pulavarty <pbadari@us.ibm.com> wrote:
> > > 
> > > I tried data=writeback mode and it didn't help :(
> > 
> > Ouch, so much for the easy way out.
> > 
> > > 
> > > unable to release the page 262070
> > > bh c0000000211b9408 flags 110029 count 1 private 0
> > > unable to release the page 262098
> > > bh c000000020ec9198 flags 110029 count 1 private 0
> > > memory offlining 3f000 to 40000 failed
> > > 
> > 
> > The only other special thing reiserfs does with the page cache is
> > file tails.  I don't suppose all of these pages are index zero in
> > files smaller than 4k?
> 
> Ahhhhhhhhhhhhh !! I am so blind :(
> 
> I have been suspecting reiserfs all along, since its executing
> fallback_migrate_page(). Actually, these buffer heads are
> backing blockdev. I guess these are metadata buffers :( 
> I am not sure we can do much with these..

Hmpf, my first reply had a paragraph about the block device inode
pages, I noticed the phrase file data pages and deleted it ;)

But, for the metadata buffers there's not much we can do.  They are
included in a bunch of different lists and the patch would
be non-trivial.

-chris


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

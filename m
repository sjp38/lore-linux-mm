Subject: Re: [PATCH/RFC] Migrate-on-fault prototype 1/5 V0.1 - separate
	unmap from radix tree replace
From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Reply-To: lee.schermerhorn@hp.com
In-Reply-To: <1141929612.8599.145.camel@localhost.localdomain>
References: <1141928931.6393.11.camel@localhost.localdomain>
	 <1141929612.8599.145.camel@localhost.localdomain>
Content-Type: text/plain
Date: Thu, 09 Mar 2006 14:05:55 -0500
Message-Id: <1141931156.6393.48.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: linux-mm <linux-mm@kvack.org>, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

On Thu, 2006-03-09 at 10:40 -0800, Dave Hansen wrote:
> On Thu, 2006-03-09 at 13:28 -0500, Lee Schermerhorn wrote:
> > @@ -3083,7 +3084,7 @@ int buffer_migrate_page(struct page *new
> > ClearPagePrivate(page);
> > set_page_private(newpage, page_private(page));
> > set_page_private(page, 0);
> > - put_page(page);
> > + put_page(page); /* transfer buf ref to newpage */
> > get_page(newpage); 
> 
> Is it just me, or do these have some serious whitespace borkage?

<heavy sigh>  Probably.  I was fighting with the mailer.  Took several
attempts to import the text files.  Even sent one to myself first,
before sending it out.  Looked OK.  

> 
> Do you have a clean version of them posted anywhere?

I just placed a tarball at:

http://free.linux.hp.com/~lts/Patches/PageMigration/

I took a look at the files in the tar ball.  Several of them do seem to
have lines consisting of a single space for what were empty context
lines in the patches.  The patches were generated via quilt which
usually complains about trailing white space and I always fix them.

Some of the lines in the discussion above the patches do seem to have
trailing spaces, but that's probably just my fat fingers...

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Content-class: urn:content-classes:message
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
Subject: RE: Which is the proper way to bring in the backing store behindan inode as an struct page?
Date: Fri, 2 Jul 2004 12:42:26 -0700
Message-ID: <F989B1573A3A644BAB3920FBECA4D25A6EBEE1@orsmsx407>
From: "Perez-Gonzalez, Inaky" <inaky.perez-gonzalez@intel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> From: Dave Hansen [mailto:haveblue@us.ibm.com]
> On Thu, 2004-07-01 at 23:34, Perez-Gonzalez, Inaky wrote:
> > Thus, what I need is a way that given the pair (inode,pgoff)
> > returns to me the 'struct page *' if the thing is cached in memory or
> > pulls it up from swap/file into memory and gets me a 'struct page *'.
> >
> > Is there a way to do this?
> 
> Do you have the VMA?  Why not just use the user mapping, and something
> like copy_to_user()?  It already handles all of the mess getting the
> page into memory and pulling it out of swap if necessary.
> 
> If you go into the page cache yourself, you'll have to deal with all of
> the usual !PageUptodate() and so forth.

No, I don't have the VMA :(; I can't really do copy_to_user() as
I just need to modify a word. I have gotten a suggestion to use
find_get_page() -- I am exploring that right now.

Thanks,

Inaky Perez-Gonzalez -- Not speaking for Intel -- all opinions are my own (and my fault)
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

Subject: Re: Which is the proper way to bring in the backing store behind
	an inode as an struct page?
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <F989B1573A3A644BAB3920FBECA4D25A6EBED8@orsmsx407>
References: <F989B1573A3A644BAB3920FBECA4D25A6EBED8@orsmsx407>
Content-Type: text/plain
Message-Id: <1088794019.28076.43.camel@nighthawk>
Mime-Version: 1.0
Date: Fri, 02 Jul 2004 11:46:59 -0700
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Perez-Gonzalez, Inaky" <inaky.perez-gonzalez@intel.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2004-07-01 at 23:34, Perez-Gonzalez, Inaky wrote:
> Thus, what I need is a way that given the pair (inode,pgoff) 
> returns to me the 'struct page *' if the thing is cached in memory or
> pulls it up from swap/file into memory and gets me a 'struct page *'.
> 
> Is there a way to do this?

Do you have the VMA?  Why not just use the user mapping, and something
like copy_to_user()?  It already handles all of the mess getting the
page into memory and pulling it out of swap if necessary.  

If you go into the page cache yourself, you'll have to deal with all of
the usual !PageUptodate() and so forth.  

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

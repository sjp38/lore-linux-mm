Date: Thu, 16 Dec 2004 22:25:13 +0000
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [patch] [RFC] move 'struct page' into its own header
Message-ID: <20041216222513.GA15451@infradead.org>
References: <E1Cf3jM-00034h-00@kernel.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <E1Cf3jM-00034h-00@kernel.beaverton.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Dec 16, 2004 at 02:04:15PM -0800, Dave Hansen wrote:
> 
> There are currently 24 places in the tree where struct page is
> predeclared.  However, a good number of these places also have to
> do some kind of arithmetic on it, and end up using macros because
> static inlines wouldn't have the type fully definied at
> compile-time.
> 
> But, in reality, struct page has very few dependencies on outside
> macros or functions, and doesn't really need to be a part of the
> header include mess which surrounds many of the VM headers.
> 
> So, put 'struct page' into structpage.h, along with a nasty comment
> telling everyone to keep their grubby mitts out of the file.
> 
> Now, we can use static inlines for almost any 'struct page'
> operations with no problems, and get rid of many of the 
> predeclarations.


What about calling it page.h?  structfoo.h sounds like a really strange
name.  And while you're at it page-flags.h should probably be merged into
it.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

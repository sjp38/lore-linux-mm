Subject: Re: Active Memory Defragmentation: Our implementation & problems
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20040204185446.91810.qmail@web9705.mail.yahoo.com>
References: <20040204185446.91810.qmail@web9705.mail.yahoo.com>
Content-Type: text/plain
Message-Id: <1075924593.27981.458.camel@nighthawk>
Mime-Version: 1.0
Date: 04 Feb 2004 11:56:33 -0800
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alok Mooley <rangdi@yahoo.com>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2004-02-04 at 10:54, Alok Mooley wrote:
> --- Dave Hansen <haveblue@us.ibm.com> wrote:
> 
> > The "work until we get interrupted and restart if
> > something changes
> > state" approach is very, very common.  Can you give
> > some more examples
> > of just how a page fault would ruin the defrag
> > process?
> > 
> 
> What I mean to say is that if we have identified some
> pages for movement, & we get preempted, the pages
> identified as movable may not remain movable any more
> when we are rescheduled. We are left with the task of
> identifying new movable pages.

Depending on the quantity of work that you're trying to do at once, this
might be unavoidable.  

I know it's a difficult thing to think about, but I still don't
understand the precise cases that you're concerned about.  Page faults
to me seem like the least of your problems.  A bigger issue would be if
the page is written to by userspace after you copy, but before you
install the new pte.  Did I miss the code in your patch that invalidated
the old tlb entries?

--dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

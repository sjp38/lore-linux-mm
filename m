Message-ID: <20040204185446.91810.qmail@web9705.mail.yahoo.com>
Date: Wed, 4 Feb 2004 10:54:46 -0800 (PST)
From: Alok Mooley <rangdi@yahoo.com>
Subject: Re: Active Memory Defragmentation: Our implementation & problems
In-Reply-To: <1075920386.27981.106.camel@nighthawk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

--- Dave Hansen <haveblue@us.ibm.com> wrote:

> The "work until we get interrupted and restart if
> something changes
> state" approach is very, very common.  Can you give
> some more examples
> of just how a page fault would ruin the defrag
> process?
> 

What I mean to say is that if we have identified some
pages for movement, & we get preempted, the pages
identified as movable may not remain movable any more
when we are rescheduled. We are left with the task of
identifying new movable pages.

-Alok

__________________________________
Do you Yahoo!?
Yahoo! SiteBuilder - Free web site building tool. Try it!
http://webhosting.yahoo.com/ps/sb/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

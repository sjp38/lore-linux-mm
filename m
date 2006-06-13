Subject: Re: [PATCH]: Adding a counter in vma to indicate the number
	of	physical pages backing it
From: Rohit Seth <rohitseth@google.com>
Reply-To: rohitseth@google.com
In-Reply-To: <200606130551.23825.ak@suse.de>
References: <1149903235.31417.84.camel@galaxy.corp.google.com>
	 <200606121958.41127.ak@suse.de>
	 <1150141369.9576.43.camel@galaxy.corp.google.com>
	 <200606130551.23825.ak@suse.de>
Content-Type: text/plain
Date: Tue, 13 Jun 2006 09:59:08 -0700
Message-Id: <1150217948.9576.67.camel@galaxy.corp.google.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@osdl.org>, Linux-mm@kvack.org, Linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 2006-06-13 at 05:51 +0200, Andi Kleen wrote:
> On Monday 12 June 2006 21:42, Rohit Seth wrote:

> 
> > I think having this information in each vma keeps the impact (of adding new counter) to very
> > low.
> > 
> > Second question is to advertize this value to user space.  Please let me
> > know what suites the most among /proc, /sys or system call (or if there
> > is any other mechanism then let me know) for a per process per segment
> > related information.
> 
> I think we first need to identify the basic need.
> Don't see why we even need per VMA information so far.

This information is for user land applications to have the knowledge of
which virtual ranges are getting actively used and which are not.
This information then can be fed into a new system call
sys_change_page_activation(pid, start_va, len, flag).  The purpose of
this system call would be to give hints to kernel that certain physical
pages are okay to be inactivated (or vice versa).   

-rohit

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Date: Mon, 5 Mar 2001 23:52:14 +0100
From: Andi Kleen <ak@muc.de>
Subject: Re: Shared mmaps
Message-ID: <20010305235214.A15922@fred.local>
References: <20010304211053.F1865@parcelfarce.linux.theplanet.co.uk> <20010305115219.A573@fred.local> <20010305175001.P1865@parcelfarce.linux.theplanet.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20010305175001.P1865@parcelfarce.linux.theplanet.co.uk>; from matthew@wil.cx on Mon, Mar 05, 2001 at 06:50:01PM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matthew Wilcox <matthew@wil.cx>
Cc: Andi Kleen <ak@muc.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 05, 2001 at 06:50:01PM +0100, Matthew Wilcox wrote:
> On Mon, Mar 05, 2001 at 11:52:19AM +0100, Andi Kleen wrote:
> > With some extensions I would also find it useful for x86-64 for the 32bit
> > mmap emulation (currently it's using a current-> hack)
> > For that flags would need to be passed to TASK_UNMAPPED_BASE.
> 
> Don't you simply check current->personality to determine whether or not
> this is a 32-bit task?

ATM yes, but LinuxThreads will eventually need to allocate memory blocks
<4GB too (due to the way the x86-64 context switch works it is much cheaper
to put thread local data pointed to by fs in <4GB) 


-Andi
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

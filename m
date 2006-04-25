Message-ID: <444DCD87.2030307@yahoo.com.au>
Date: Tue, 25 Apr 2006 17:19:35 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: Page host virtual assist patches.
References: <20060424123412.GA15817@skybase> <20060424180138.52e54e5c.akpm@osdl.org>
In-Reply-To: <20060424180138.52e54e5c.akpm@osdl.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>, linux-mm@kvack.org, frankeh@watson.ibm.com, rhim@cc.gatech.edu
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> Martin Schwidefsky <schwidefsky@de.ibm.com> wrote:
> 
>> The basic idea of host virtual assist (hva) is to give a host system
>> which virtualizes the memory of its guest systems on a per page basis
>> usage information for the guest pages. The host can then use this
>> information to optimize the management of guest pages, in particular
>> the paging. This optimizations can be used for unused (free) guest
>> pages, for clean page cache pages, and for clean swap cache pages.
> 
> 
> This is pretty significant stuff.  It sounds like something which needs to
> be worked through with other possible users - UML, Xen, vware, etc.
> 
> How come the reclaim has to be done in the host?  I'd have thought that a
> much simpler approach would be to perform a host->guest upcall saying
> either "try to free up this many pages" or "free this page" or "free this
> vector of pages"?

Definitely. The current patches seem like just an extra layer to do
everything we can already -- reclaim unused pages and populate them
again when they get touched.

And complex they are. Having the core VM have to know about all this
weird stuff seems... not good.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

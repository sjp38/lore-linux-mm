Date: Tue, 11 Feb 2003 21:20:26 +0000
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [rfc][api] Shared Memory Binding
Message-ID: <20030211212026.A21174@infradead.org>
References: <3E49635A.70906@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3E49635A.70906@us.ibm.com>; from colpatch@us.ibm.com on Tue, Feb 11, 2003 at 12:55:54PM -0800
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matthew Dobson <colpatch@us.ibm.com>
Cc: "Martin J. Bligh" <mbligh@aracnet.com>, Michael Hohnbaum <hohnbaum@us.ibm.com>, lse-tech@lists.sourceforge.net, Andrew Morton <akpm@digeo.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 11, 2003 at 12:55:54PM -0800, Matthew Dobson wrote:
> Hello All,
> 	I've got a pseudo manpage for a new call I'm attempting to implement: 
> shmbind().  The idea of the call is to allow userspace processes to bind 
> shared memory segments to particular nodes' memory and do so according 
> to certain policies.  Processes would call shmget() as usual, but before 
> calling shmat(), the process could call shmbind() to set up a binding 
> for the segment.  Then, any time pages from the shared segment are 
> faulted into memory, it would be done according to this binding.
> 	Any comments about the attatched manpage, the idea in general, how to 
> improve it, etc. are definitely welcome.

Do we really need to add more mess to the broken sysvipc interfaces?
I think an shm_open_on_node call for posix-style shm would be a much better
idea.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

Date: Wed, 2 May 2001 11:25:51 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: About reading /proc/*/mem
Message-ID: <20010502112551.B26638@redhat.com>
References: <m1oftdozsi.fsf@frodo.biederman.org> <Pine.GSO.4.21.0105011231330.9771-100000@weyl.math.psu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.GSO.4.21.0105011231330.9771-100000@weyl.math.psu.edu>; from viro@math.psu.edu on Tue, May 01, 2001 at 12:35:29PM -0400
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alexander Viro <viro@math.psu.edu>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, Richard F Weber <rfweber@link.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, May 01, 2001 at 12:35:29PM -0400, Alexander Viro wrote:
> 
> On 1 May 2001, Eric W. Biederman wrote:
> 
> > > Unfortunately, ptrace() probobally isn't going to allow me to do that.  
> > > So my next question is does opening /proc/*/mem force the child process 
> > > to stop on every interrupt (just like ptrace?)
> > 
> > 
> > The not stopping the child should be the major difference between
> > /proc/*/mem and ptrace.
> 
> Could somebody tell me what would one do with data read from memory
> of process that is currently running?

As long as we have the appropriate page table lock while doing the
physical page lookup, and grab a refcount on the page with the lock
held, we'll get a valid physical memory location to read to the user.
We don't need any stronger guarantee than that --- if the target
process is playing mmap games or modifying the memory while the read
happens, the result is unpredictable but safe.

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

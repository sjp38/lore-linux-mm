Subject: Re: About reading /proc/*/mem
References: <3AEEBB22.9030801@link.com>
From: ebiederm@xmission.com (Eric W. Biederman)
Date: 01 May 2001 09:27:09 -0600
In-Reply-To: "Richard F Weber"'s message of "Tue, 01 May 2001 09:33:22 -0400"
Message-ID: <m1oftdozsi.fsf@frodo.biederman.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Richard F Weber <rfweber@link.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

"Richard F Weber" <rfweber@link.com> writes:

> Ok, so as a rehash, the ptrace & open(),lseek() on /proc/*/mem should 
> both work about the same.  After a lot of struggling, I've gotten the 
> ptrace to work right & spit out the data I want/need.  However there is 
> one small problem, SIGSTOP.
> 
> ptrace() appears to set up the child process to do a SIGSTOP whenever 
> any interrupt is received.  Which is kind of a bad thing for what I'm 
> looking to do.  I guess I'm trying to write a non-intrusive debugger 
> that can be used to view static variables stored in the heap of an 
> application.
> 
> On other OS's, this can be done just by popping open /proc/*/mem, and 
> reading the data as needed, allowing the child process to continue 
> processing away as if nothing is going on.  I'm looking to do the same 
> sort of task under Linux. 
> 
> Unfortunately, ptrace() probobally isn't going to allow me to do that.  
> So my next question is does opening /proc/*/mem force the child process 
> to stop on every interrupt (just like ptrace?)


The not stopping the child should be the major difference between
/proc/*/mem and ptrace.


> Second, I would imagine opening /dev/mem (or /proc/kcore) would get me 
> into the physical memory of the system itself.  How would I know what 
> the starting physical memory addresses of a processes data is to start at:

You don't even want to go there.  You've got the wrong model in your head.

> 0x08049000-0x804a000 are mapped to the physical address of 0x718368.  
Nope 0x718368 is the inode of an on-disk file.

> However Going to this address, and then doing an lseek(SEEK_CUR)out to 
> my expected variable offset doesn't get me the result I'm expecting.  Is 
> the 0x718368 the right location to be looking at, or is there some 
> translation that needs to get done (* by page size, translate into 
> hex/from hex, etc.) I can't find any documentation indicating what each 
> column represents so it's just a stab on my part.

man proc or reading the source works.

> Thanks for the good information so far.
> 
> --Rich
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux.eu.org/Linux-MM/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

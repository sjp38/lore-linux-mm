Date: Fri, 22 Oct 1999 10:59:25 -0400 (EDT)
From: James Simmons <jsimmons@edgeglobal.com>
Subject: Re: page faults
In-Reply-To: <14352.24920.122613.498709@dukat.scot.redhat.com>
Message-ID: <Pine.LNX.4.10.9910221054550.23698-100000@imperial.edgeglobal.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: "Benjamin C.R. LaHaise" <blah@kvack.org>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 22 Oct 1999, Stephen C. Tweedie wrote:

> Hi,
> 
> On Thu, 21 Oct 1999 15:40:15 -0400 (EDT), "Benjamin C.R. LaHaise"
> <blah@kvack.org> said:
> 
> > On Thu, 21 Oct 1999, James Simmons wrote:
> >> Quick question. If two processes are sharing the same memory but no page
> >> fault has happened. THen process A causes a page fault. If process B tries
> >> to access the page that process A already page fault will process B cause
> >> another page fault. Or do page faults only happen once no matter how many
> >> process access it. 
> 
> > Only the first time the page is accessed is there a fault to put the entry
> > into the page table, regardless of the processes sharing the page.  
> 
> No.  If a process mmap()s a file and forks, then the two processes will
> page fault independently.  Similarly if two separate processes mmap()
> the same file, they will page fault independently.  Finally, if a
> process has a data page which becomes faulted out and the process forks,
> then the two resuling processes will both have to take independent page
> faults to map the page.
> 
> However, there will only ever be one major fault (ie. one fault which
> has to bring data in from disk).  If multiple processes share the same
> page, then the second and all subsequent processes to fault on that page
> will take a minor page fault which will just find the existing page in
> memory and map that into the faulting process's page tables.

Thank you for that answer. I remember you told me that threads under linux
is defined as two processes sharing the same memory. So when a minor
page fault happens by anyone one process will both process page tables get
updated? Or does the other process will have a minor page itself
independent of the other process? 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/

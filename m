Date: Wed, 16 Feb 2005 11:23:35 -0800
From: Paul Jackson <pj@sgi.com>
Subject: Re: manual page migration -- issue list
Message-Id: <20050216112335.6d0cf44a.pj@sgi.com>
In-Reply-To: <20050216160823.GA10620@lnx-holt.americas.sgi.com>
References: <42128B25.9030206@sgi.com>
	<20050215165106.61fd4954.pj@sgi.com>
	<20050216015622.GB28354@lnx-holt.americas.sgi.com>
	<20050215202214.4b833bf3.pj@sgi.com>
	<20050216092011.GA6616@lnx-holt.americas.sgi.com>
	<20050216022009.7afb2e6d.pj@sgi.com>
	<20050216113047.GA8388@lnx-holt.americas.sgi.com>
	<20050216074550.313b1300.pj@sgi.com>
	<20050216160823.GA10620@lnx-holt.americas.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robin Holt <holt@sgi.com>
Cc: raybry@sgi.com, linux-mm@kvack.org, ak@muc.de, haveblue@us.ibm.com, marcello@cyclades.com, stevel@mwwireless.net, peterc@gelato.unsw.edu.au
List-ID: <linux-mm.kvack.org>

Robin wrote:
> Reading /proc/<pid>maps just scans through the vmas and not the
> address space.

Yes - you're right.

So the number of system calls in your example of a few hours ago, using
your preferred array API, if you include the reads of each tasks
/proc/<pid>/maps file, is about equal to the number of tasks, right?

And I take it that the user code you asked Ray about looks at these
maps files for each of the tasks to be migrated, identifies each
mapped range of each mapped object (mapped file or whatever) and
calculates a fairly minimum set of tasks and virtual address ranges
therein, sufficient to cover all the mapped objects that should
be migrated, thus minimizing the amount of scanning that needs
to be done of individual pages.

And further I take it that you recommend the above described code [to
find a fairly minimum set of tasks and address ranges to scan that will
cover any page of interest] be put in user space, not in the kernel (a
quite reasonable recommendation).

Why didn't your example have some writable private pages?  Wouldn't such
pages be commonplace, and wouldn't they have to be migrated for each
thread, resulting in at least N calls to the new sys_page_migrate()
system call, for N tasks, rather than the 3 calls in your example?

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.650.933.1373, 1.925.600.0401
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

Date: Tue, 22 Apr 2003 14:01:46 -0400
From: Benjamin LaHaise <bcrl@redhat.com>
Subject: Re: Large-footprint processes in a batch-processing-like scenario
Message-ID: <20030422140146.E2944@redhat.com>
References: <200304221724.h3MHOCKP001910@pacific-carrier-annex.mit.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200304221724.h3MHOCKP001910@pacific-carrier-annex.mit.edu>; from pshuang@alum.mit.edu on Tue, Apr 22, 2003 at 01:24:12PM -0400
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ping Huang <pshuang@alum.mit.edu>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 22, 2003 at 01:24:12PM -0400, Ping Huang wrote:
> I received only one reply from <wli@holomorphy.com>, who CC'ed this
> email list, so there is no need to provide a "summary" as promised.
> 
> I would still interested in any ideas that people might have for
> tuning the throughput for my work load, short of doing a general
> implementation of load control for the Linux kernel from scratch.

In the systems I've used and heard about, people tend to limit the load at 
another level where more intelligent scheduling decisions can be made.  In 
other cases people have run multiple jobs on clusters that swap in order to 
get better throughput on the large matrix operations which already exceed 
the size of memory.

All told, the best implementation is probably one that is in user space and 
simply does a kill -STOP and -CONT on jobs which are competing.  Any 
additional policy could then be added to the configuration by the admin at 
run time, unlike a kernel implementation.

		-ben
-- 
Junk email?  <a href="mailto:aart@kvack.org">aart@kvack.org</a>
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

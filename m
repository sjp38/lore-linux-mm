Date: Tue, 22 Apr 2003 20:15:54 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: Large-footprint processes in a batch-processing-like scenario
Message-ID: <20030423031554.GH8931@holomorphy.com>
References: <200304221724.h3MHOCKP001910@pacific-carrier-annex.mit.edu> <20030422140146.E2944@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030422140146.E2944@redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin LaHaise <bcrl@redhat.com>
Cc: Ping Huang <pshuang@alum.mit.edu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 22, 2003 at 01:24:12PM -0400, Ping Huang wrote:
>> I received only one reply from <wli@holomorphy.com>, who CC'ed this
>> email list, so there is no need to provide a "summary" as promised.
>> I would still interested in any ideas that people might have for
>> tuning the throughput for my work load, short of doing a general
>> implementation of load control for the Linux kernel from scratch.

On Tue, Apr 22, 2003 at 02:01:46PM -0400, Benjamin LaHaise wrote:
> In the systems I've used and heard about, people tend to limit the load at 
> another level where more intelligent scheduling decisions can be made.  In 
> other cases people have run multiple jobs on clusters that swap in order to 
> get better throughput on the large matrix operations which already exceed 
> the size of memory.
> All told, the best implementation is probably one that is in user space and 
> simply does a kill -STOP and -CONT on jobs which are competing.  Any 
> additional policy could then be added to the configuration by the admin at 
> run time, unlike a kernel implementation.

There were some issues mentioned that had to do with swap fragmentation
and poor page replacement behavior in the presence of random access
patterns, and it sounds like he's already doing kill -STOP and -CONT
from this:

On Fri, Apr 18, 2003 at 07:05:46PM -0400, Ping Huang wrote:
> - In practice, if I start all 5 application instances on a single 3GB
>   PC, and signal instances 2-5 to go to sleep, and let instance 1 run
>   for an hour, then signal instance 1 to go to sleep and signal
>   instance 2 to wake up, the Linux kernel will page in instance 2's
>   2GB working set, but rather slowly.  The application's memory access
>   patterns are close enough to being random that Linux is essentially
>   paging in its working set randomly, and this is resulting in very
>   slow page-in rates compared to the 25MB/sec. bandwidth rate.
>   Instead of being bandwidth limited, the observed paging behavior in
>   this case seems disk seek limited.  Increasing the value of

I don't know what other people's requirements are. What was asked was
this:

On Fri, Apr 18, 2003 at 07:05:46PM -0400, Ping Huang wrote:
> I'm trying to figure out if there is an efficient way to coerce the
> Linux kernel to effectively swap (not demand-page) between multiple
> processes which will not all fit together into physical memory.  I'd

and I gave what I thought would be enough information to do it with. It
really sounded like he was pointing directly at load control from that.
It also sounds like he's in a forced overcommitment scenario from other
parts of the post.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

Date: Mon, 7 Aug 2000 20:26:40 -0700
From: David Gould <dg@suse.com>
Subject: Re: RFC: design for new VM
Message-ID: <20000807202640.A12492@archimedes.suse.com>
References: <8725692F.0079E22B.00@d53mta03h.boulder.ibm.com> <200008071740.KAA25895@eng2.sequent.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <200008071740.KAA25895@eng2.sequent.com>; from Gerrit.Huizenga@us.ibm.com on Mon, Aug 07, 2000 at 10:40:52AM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Gerrit.Huizenga@us.ibm.com
Cc: Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

On Mon, Aug 07, 2000 at 10:40:52AM -0700, Gerrit.Huizenga@us.ibm.com wrote:
... 
>                                                 ...  Another mechanism,
> and the one that we chose in our operating system, was to use a modified
> process resident set sizes as the machanism for page management.  The
> basic modifications are to make the RSS tuneable system wide as well
> as per process.  The RSS size "flexes" based on available memory and
> a processes page fault frequency (PFF).  Frequent page faults force the
> RSS to increase, infrequent page faults cause a processes resident size
> to shrink.  When memory pressure mounts, the running process manages
> itself a little more agressively; processes which have "flexed"
> their resident set size beyond their system or per process recommended
> maxima are among the first to lose pages.  And, when pressure can not
> be addressed to RSS management, swapping starts.

Hmmm, the vm discussion and the lack of good documentation on vm systems
has sent me back to reread my old "VMS Internals and Data Structures" book,
at least for historical perspective. The above description of per process
RSS size adjustment controlled by page fault rate sounds quite similar to the
scheme in VMS.

Basically in VMS, processes page against themselves, not against the system
as a whole. A process grows or shrinks based on its recent pagefault
rate which is configurable with upper and lower targets. This happens
more or less continously. In addition the system has global goals for free
and dirty pages and in response to memory pressure will start cleaning pages,
(via a page writer task), or if need be, stealing pages from processes or
even swapping whole processes (via swapper task).

I am probably making a hash of decribing this, and of course VMS is not the
last word by any means, but the system was very tunable, and had specific
explicit mechanisms to attain many of the goals of vm system. As such it
is an instructive example if only to point out the problems to be solved,
and at least one way to solve them. If you wish a real description there
is always the "big black book" by Kennah and Bates (IIRC), which has
about 150 pages just on the vm. For a short summary, I found a couple
of web pages about the t:

http://cctr.umkc.edu/vms/72final/6491/6491pro_002.html#memory_chap
http://cctr.umkc.edu/vms/72final/6491/6491pro_003.html

I hope someone finds this useful...

-dg
  
-- 
David Gould                                                 dg@suse.com
SuSE, Inc.,  580 2cd St. #210,  Oakland, CA 94607          510.628.3380
"I sense a disturbance in the source"  -- Alan Cox
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

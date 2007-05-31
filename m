Subject: Re: [PATCH] Document Linux Memory Policy
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20070531122544.fd561de4.pj@sgi.com>
References: <1180467234.5067.52.camel@localhost>
	 <Pine.LNX.4.64.0705291247001.26308@schroedinger.engr.sgi.com>
	 <1180544104.5850.70.camel@localhost>
	 <Pine.LNX.4.64.0705301042320.1195@schroedinger.engr.sgi.com>
	 <20070531122544.fd561de4.pj@sgi.com>
Content-Type: text/plain
Date: Thu, 31 May 2007 16:22:42 -0400
Message-Id: <1180642962.5091.192.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, akpm@linux-foundation.org, ak@suse.de
List-ID: <linux-mm.kvack.org>

On Thu, 2007-05-31 at 12:25 -0700, Paul Jackson wrote:
> > They have to since they may be used to change page locations when policies 
> > are active. There is a libcpuset library that can be used for application 
> > control of cpusets. I think Paul would disagree with you here.
> 
> In the most common usage, a batch scheduler uses cpusets to control
> a jobs memory and  placement, and application code within the job uses
> the memory policy calls (mbind, set_mempolicy) and scheduler policy
> call (set_schedaffinity) to manage its detailed placement.
> 
<snip>

Paul:  Excellent writeup.  Thanks.  No disrespect implied by the <snip>.

> 
> Unfortunately there are a couple of details that leak through:
>  1) big apps using scheduler and memory policy calls often want to
>     know how "big" their machine is, which changes under cpusets
>     from the physical size of the system, and
>  2) the sched_setaffinity, mbind and set_mempolicy calls take hard
>     physical CPU and Memory Node numbers, which change under migration
>     non-transparently.
> 
> Therefore I have in libcpuset two kinds of routines:
>  1) a large powerful set used by heavy weight batch schedulers to
>     provide sophisticated job placement, and
>  2) a small simple set used by applications that provide an interface
>     to sched_setaffinity, mbind and set_mempolicy that is virtualized
>     to the cpuset, providing cpuset relative CPU and Memory Node
>     numbering and cpuset relative sizes, safely usable from an
>     application across a migration to different nodes, without
>     application awareness.
> 
> The ancient, Linux 2.4 kernel based, libcpuset on oss.sgi.com is
> really ancient and not relevant here.  The cpuset mechanism in
> Linux 2.6 is a complete redesign from SGI's cpumemset mechanism
> for Linux 2.4 kernels.

I saw this one on the site and it did appear quite old.  I haven't come
across libcpuset "in the wild" yet, but I like the notion of cpuset
relative ids ["container namespaces"?].  I'd also be happy if things
like numa_membind() in libnuma returned just the available mems, hard
physical ids and all.

> 
> SGI releases libcpuset under GPL license, though currently I've just
> set this up for customers of SGI's software.  Someday I hope to get
> the current libcpuset up on oss.sgi.com, for all to use.

I'll be looking for it...

Thanks, again

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

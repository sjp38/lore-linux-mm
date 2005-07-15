Message-Id: <200507150555.j6F5tMg10646@unix-os.sc.intel.com>
From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Subject: RE: [NUMA] Display and modify the memory policy of a process through /proc/<pid>/numa_policy
Date: Thu, 14 Jul 2005 22:55:21 -0700
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
In-Reply-To: <Pine.LNX.4.62.0507142152400.2139@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: 'Christoph Lameter' <clameter@engr.sgi.com>
Cc: linux-mm@kvack.org, linux-ia64@vger.kernel.org, pj@sgi.com
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote on Thursday, July 14, 2005 10:08 PM
> On Thu, 14 Jul 2005, Chen, Kenneth W wrote:
> > > Additionally the patch also adds write capability to the "numa_maps". One
> > > can write a VMA address followed by the policy to that file to change the
> > > mempolicy of an individual virtual memory area. i.e.
> > 
> > This looks a lot like a back door access to libnuma and numactl capability.
> > Are you sure libnuma and numactl won't suite your needs?
> 
> The functionality offered here is different. numactl's main concern is 
> starting processes. libnuma is mostly concerned with a process 
> controlling its own memory allocation.
> 
> This is an implementation that deals with monitoring and managing running 
> processes. For an effective batch scheduler we need outside control 
> over memory policy.

I want to warn you that controlling via external means to the app with numa
policy is extremely unreliable and difficult.  Since in-kernel numa policy
is enforced for the new allocation.  When pages inside the vma have already
been touched before you echo the policy into the proc file, it has no effect.

That means one need some synchronization point between sys admin echo a
desired policy into the /proc file to the time app touches the memory.  It
sound like you have another patch in the pipeline to address that.  But
there is always some usage model this will break down (me thinking interleave
mode...).


> It needs to be easy to see what is going on in the system (numa_maps)

Yeah, I like the numa_maps a lot :-)


- Ken

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

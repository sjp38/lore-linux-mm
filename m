Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 400356B0002
	for <linux-mm@kvack.org>; Tue,  2 Apr 2013 08:54:13 -0400 (EDT)
Date: Tue, 2 Apr 2013 13:54:08 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: NUMA Autobalancing Kernel 3.8
Message-ID: <20130402125408.GG32241@suse.de>
References: <515A87C3.1000309@profihost.ag>
 <20130402104844.GE32241@suse.de>
 <515AC3EE.1030803@profihost.ag>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <515AC3EE.1030803@profihost.ag>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, srikar@linux.vnet.ibm.com, aarcange@redhat.com, mingo@kernel.org, riel@redhat.com

On Tue, Apr 02, 2013 at 01:41:34PM +0200, Stefan Priebe - Profihost AG wrote:
> Am 02.04.2013 12:48, schrieb Mel Gorman:
> > On Tue, Apr 02, 2013 at 09:24:51AM +0200, Stefan Priebe - Profihost AG wrote:
> >> Hello list,
> >>
> >> i was trying to play with the new NUMA autobalancing feature of Kernel 3.8.
> >>
> >> But if i enable:
> >> CONFIG_ARCH_USES_NUMA_PROT_NONE=y
> >> CONFIG_NUMA_BALANCING_DEFAULT_ENABLED=y
> >> CONFIG_NUMA_BALANCING=y
> >>
> >> i see random process crashes mostly in libc using vanilla 3.8.4.
> >>
> > 
> > Any more details than that? What sort of crashes? Anything in the kernel
> > log? Any particular pattern to the crashes? Any means of reliably
> > reproducing it? 3.8 vanilla, 3.8-stable or 3.8 with any other patches
> > applied?
> 
> Sorry for missing information.
> 
> > Any more details than that?
> Sadly not i just see a crash line in the kernel log - see below.
> 
> > What sort of crashes?
> Mostly the processes just die but i've also seen processes consuming
> 100% CPU all the time or even just doing nothing anymore.
> 

When you see the 100% CPU usage can you cat /proc/PID/stack a couple of
times and post it here? That might give a hint as to where it's going wrong.

> > Anything in the kernel log?
> Three examples:
> pigz[10194]: segfault at 0 ip           (null) sp 00007f6197ffed50 error
> 14 in pigz[400000+e000]
> 
> rbd[2811]: segfault at b8 ip 00007f73c2d51b9e sp 00007f73bcae3b40 error
> 4 in librados.so.2.0.0[7f73c2afe000+3b9000]
> 
> rbd[1805]: segfault at 0 ip 00007f60c28dceb4 sp 00007f60b7ffd1f8 error 4
> in ld-2.11.3.so[7f60c28cc000+1e000]
> 
> > Any particular pattern to the crashes? Any means of reliably
> > reproducing it?
> No i just need to run some task and after some time they die or hang
> forever. I have this on 10 different E5-2640 and also on E56XX. I can
> "fix" this by:
>   1.) putting all memory to just ONE CPU
>   2.) Disable NUMA Balancing
> 

That does point the finger at the automatic balancing.

> > 3.8 vanilla, 3.8-stable or 3.8 with any other patches
> > applied?
> 3.8.4 without any patches.
> 

Did it happen in 3.8?

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

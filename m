Received: from CONVERSION-DAEMON.jhuml4.jhu.edu by jhuml4.jhu.edu
 (PMDF V6.0-24 #47563) id <0G4W00301QEF8L@jhuml4.jhu.edu> for
 linux-mm@kvack.org; Fri, 01 Dec 2000 16:01:27 -0500 (EST)
Received: from aa.eps.jhu.edu (aa.eps.jhu.edu [128.220.24.92])
 by jhuml4.jhu.edu (PMDF V6.0-24 #47563)
 with ESMTP id <0G4W001NXQEETQ@jhuml4.jhu.edu> for linux-mm@kvack.org; Fri,
 01 Dec 2000 16:01:26 -0500 (EST)
Date: Fri, 01 Dec 2000 15:59:29 -0500 (EST)
From: afei@jhu.edu
Subject: Re: Problems accessing > 2GB RAM per process
In-reply-to: <3A2809F9.C3360160@astro.wisc.edu>
Message-id: <Pine.GSO.4.05.10012011558580.25289-100000@aa.eps.jhu.edu>
MIME-version: 1.0
Content-type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: jansen <jansen@astro.wisc.edu>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Are you running the program as root or normal user? Is there a resource
limit capped on normal user?

Fei

On Fri, 1 Dec 2000, jansen wrote:

> Hi,
> 
> I have just gotten a Intel Linux box with 4GB of RAM and am
> having problems accessing more than 2 GB of RAM in a single
> process. I am using 2.2.18pre11-va1.1smp on a VA Linux machine
> which has the BIGMEM stuff compiled in, and I'm currently using
> the RedHat 7.0 (and updated) gcc and glibc stuff installed (ie:
> binutils-2.10.0.18-1,gcc-2.96-54, kgcc-1.1.2-40, gcc-g77-2.96-54,
> glibc-devel-2.2-5, glibc-2.2-5).  I'm compiling simple test
> programs in C and Fortran with "-static" and still I can't access
> RAM beyond 2GB (it was about 1.5 GB without the "-static" switch).
> The symptom is a SEGV when accessing an array in Fortran and in
> C I am unable to malloc beyond 2GB.  Any suggestions on what I'm
> doing wrong?
> 
> Is there any way to access more than 3 GB per process with this
> setup and if so how?
> 
> Thanks and sorry if this is FAQ, I couldn't find this adequately
> answered anywhere.
> 
> Here's what it says in meminfo:
> 
> #cat /proc/meminfo
>         total:    used:    free:  shared: buffers:  cached:
> Mem:  4160315392 406388736 3753926656        0 71380992 233754624
> Swap: 4293509120        0 4293509120
> MemTotal:   4062808 kB
> MemFree:    3665944 kB
> MemShared:        0 kB
> Buffers:      69708 kB
> Cached:      228276 kB
> BigTotal:   3080188 kB
> BigFree:    3051196 kB
> SwapTotal:  4192880 kB
> SwapFree:   4192880 kB
> 
> -- 
> 
> 
> ------- Stephan
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux.eu.org/Linux-MM/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

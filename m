Received: from ds02e00.directory.ray.com (ds02e00.rsc.raytheon.com [147.25.130.245])
	by bos-gate3.raytheon.com (8.11.0.Beta3/8.11.0.Beta3) with ESMTP id e7MDLBQ12360
	for <Linux-MM@kvack.org>; Tue, 22 Aug 2000 09:21:11 -0400 (EDT)
Received: from rtshou-ds01.hou.us.ray.com (localhost [127.0.0.1])
	by ds02e00.directory.ray.com (8.9.3/8.9.3) with ESMTP id JAA18141
	for <Linux-MM@kvack.org>; Tue, 22 Aug 2000 09:21:09 -0400 (EDT)
From: Mark_H_Johnson@Raytheon.com
Subject: Re: Memory partitioning
Message-ID: <OFD6D15CC0.5EB71010-ON86256943.00482136@hou.us.ray.com>
Date: Tue, 22 Aug 2000 08:18:58 -0500
MIME-Version: 1.0
Content-type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: santosh@sony.co.in
Cc: Linux-MM@kvack.org
List-ID: <linux-mm.kvack.org>

Hmm. We've been looking into moving a real time computer emulation [to run
flight software in a simulator] to Linux and have similar problems. Our
solution doesn't involve partitioning the MMU though. Similar to the
MKLinux example below, we're willing to use the part of Linux memory
management where it helps - allocating storage and locking it into memory.
Where we've focused our attention is the handling of page faults & related
traps. We want something like a "secondary interrupt dispatch table" that
is enabled on a per process basis. There's some small overhead to do the
extra IF statement at the start of each interrupt handler, but it gives us
the means of selecting which code we want to run [standard Linux, RT Linux,
or our own]. Is that kind of capability what you are looking for or
something else?

--Mark H Johnson
  <mailto:Mark_H_Johnson@raytheon.com>


                                                                                                                    
                    Santosh                                                                                         
                    Eraniose             To:     Linux-MM@kvack.org                                                 
                    <santosh@sony        cc:     (bcc: Mark H Johnson/RTS/Raytheon/US)                              
                    .co.in>              Subject:     Memory partitioning                                           
                                                                                                                    
                    08/22/00                                                                                        
                    05:32 AM                                                                                        
                                                                                                                    
                                                                                                                    



Hi,
Is it possible to partition the MMU such that multiple OS
can run on the same platform.
In all examples I see like MKLinux , the mem mgmt of Linux is mapped to the
underlying Mach kernel.
The other extreme is as in RTAI (Real time App Interface), where the MMU is

handled by linux, but the
scheduling is done by RTAI.

Thanks
Santosh Eraniose
-----------------------------------------------
Member Technical
Sony Software Architecture Lab
Bangalore
-----------------------------------------------

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

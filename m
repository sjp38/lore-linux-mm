Date: Mon, 4 Sep 2000 09:51:57 +0200
From: Ralf Baechle <ralf@uni-koblenz.de>
Subject: Re: Memory partitioning
Message-ID: <20000904095157.A1186@bacchus.dhis.org>
References: <4.3.2.7.0.20000822155755.00aa3e00@192.168.1.9>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4.3.2.7.0.20000822155755.00aa3e00@192.168.1.9>; from santosh@sony.co.in on Tue, Aug 22, 2000 at 04:02:51PM +0530
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Santosh Eraniose <santosh@sony.co.in>
Cc: Linux-MM@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 22, 2000 at 04:02:51PM +0530, Santosh Eraniose wrote:

> Is it possible to partition the MMU such that multiple OS
> can run on the same platform.
> In all examples I see like MKLinux , the mem mgmt of Linux is mapped to the
> underlying Mach kernel.
> The other extreme is as in RTAI (Real time App Interface), where the MMU is 
> handled by linux, but the
> scheduling is done by RTAI.

Several approaches:

 - IBM S390 can partition the hardware.  In cooperation with IBM's VM this
   allows to completly - and efficiently - subdivide the machine into multiple
   virtual machines.  VMs can even nest.
 - Less perfect due to not available VM-like software and no support of the
   hardware as on the S390 for example Sun's E10000 or SGI Origin 2000/3000
   offer partitioning.  This style of partitioning is mostly implemented
   by the hardware of the machines.

The two approaches guarantee that even a virtual machine or partition that goes nuts can't crash another virtual machine or partition.

 - Not implemented but in theory implementable would be multiple kernels
   running on top RTLinux's realtime kernel.

  Ralf
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

From: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Message-Id: <200008031920.MAA08999@google.engr.sgi.com>
Subject: MIPS64 port 
Date: Thu, 3 Aug 2000 12:20:34 -0700 (PDT)
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
Cc: torvalds@transmeta.com, alan@lxorguk.ukuu.org.uk, ulfc@google.engr.sgi.com, Kanoj Sarcar <kanoj@google.engr.sgi.com>, ralf@oss.sgi.com
List-ID: <linux-mm.kvack.org>

Hi all,

Just thought I would send out a note outlining the state of the mips64
port. Ralf, Ulf and I have been actively working past few months to
bring up Linux on the SGI ccNUMA machines.

The executive summary: we have achieved multiuser boot on o200 and o2000s.
The largest configuration is a 32p, 16node machine (only approx 4G worth
of memory was populated over the 16 nodes, the system can take 4G * 16
node worth of memory). This machine has 10 PCI busses, with 24 scsi
controllers and 10 disks. (Sample output is at

    http://oss.sgi.com/projects/LinuxScalability/download/mips64.out)

If you are interested in the system architecture and details of the
port, read on. The o2000s use R10000 series of MIPS processors. Each
machine is comprised of modules, each module has 4 node boards with max
2 cpus and 4G memory on each node, and IO boards and routers. In a module,
the two alternate node boards are each connected to a XBOW. Each XBOW
possibly is connected on the other side to a number of PCI busses, which
is what the IO boards connect to. Apart from this, there are routers in
the system that provide connection paths between all memory to all cpus,
to create a true CC-NUMA architecture.

On the software side, we are still struggling with compiler and binutils
issues. The kernel itself is 64 bits, created by cross compiling on an
ia32 box. We have not attempted 64 bit user program compilation or
execution. The root disk is currently very close to the MIPS/Indy root
disks. The architecture specific code uses the CONFIG_DISCONTIGMEM code
to support memory on all nodes. The architecture specific NUMA features
currently are: 1. replicate the kernel text on all nodes, so that no one
node becomes a memory hot spot (unfortunately, the kernel data has to
reside on only one node). 2. replicate low level excpetion handler code
on all nodes. The architecture code also turns on CONFIG_NUMA to take
advantage of node-local page allocations. (A CONFIG_NUMA patch that I
have been submitting to Linus was put into the kernel in test6-pre1).
For more information on NUMA and ongoing work, refer to

        http://oss.sgi.com/projects/numa

The purpose of doing this port is to boot Linux on bigger systems that
we have, in order to do cpu/memory scalability studies. This also lets
us do NUMA performance work in the future. Another advantage is to
be able to leverage this work on the upcoming SGI CC-NUMA Itanium
boxes, which will be an SGI supported product. Initial results from
scalability studies using mips64 is documented at

        http://oss.sgi.com/projects/LinuxScalability

Kanoj

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

Message-ID: <402B5BB1.2080303@gadsdon.giointernet.co.uk>
Date: Thu, 12 Feb 2004 10:55:45 +0000
From: Robert Gadsdon <robert@gadsdon.giointernet.co.uk>
MIME-Version: 1.0
Subject: Re: 2.6.3-rc2-mm1- still "Badness in kobject_get"
References: <fa.hqqo825.1u6gqhj@ifi.uio.no>
In-Reply-To: <fa.hqqo825.1u6gqhj@ifi.uio.no>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Linux version 2.6.3-rc2-mm1 (root@xxxxxxxxxxxxxx) (gcc version 3.3.2 
20031022 (Red Hat Linux 3.3.2-1)) #1 SMP Thu Feb 12 10:10:26 GMT 2004
.....
......
ohci1394: $Rev: 1118 $ Ben Collins <bcollins@debian.org>
ohci1394: fw-host0: OHCI-1394 1.0 (PCI): IRQ=[18] 
MMIO=[febfe800-febfefff]  Max Packet=[2048]
raw1394: /dev/raw1394 device initialized
blk: queue c1321c00, I/O limit 4095Mb (mask 0xffffffff)
blk: queue c1321800, I/O limit 4095Mb (mask 0xffffffff)
ieee1394: Host added: ID:BUS[0-00:1023]  GUID[090050c50000046f]
Badness in kobject_get at lib/kobject.c:431
Call Trace:
  [<c0239e96>] kobject_get+0x36/0x40
  [<c027d253>] get_device+0x13/0x20
  [<c027de79>] bus_for_each_dev+0x59/0xc0
  [<d093e6f5>] nodemgr_node_probe+0x55/0x120 [ieee1394]
  [<d093e5a0>] nodemgr_probe_ne_cb+0x0/0x90 [ieee1394]
  [<d093eae8>] nodemgr_host_thread+0x168/0x190 [ieee1394]
  [<d093e980>] nodemgr_host_thread+0x0/0x190 [ieee1394]
  [<c010ac15>] kernel_thread_helper+0x5/0x10

Unable to handle kernel paging request at virtual address 53565755
  printing eip:
53565755
*pde = 00000000
Oops: 0000 [#1]
PREEMPT SMP
CPU:    0
EIP:    0060:[<53565755>]    Not tainted VLI
EFLAGS: 00010206
EIP is at 0x53565755
eax: 53565755   ebx: d09714e8   ecx: cf8d3f9c   edx: 00000000
esi: d093e110   edi: 00000000   ebp: d093d4a0   esp: cf8d3f40
ds: 007b   es: 007b   ss: 0068
Process knodemgrd_0 (pid: 1326, threadinfo=cf8d2000 task=cfa24c00)
Stack: c0239f23 d09714e8 d09714c4 d09714cc d0971420 cfd979c8 c027de8f 
d09714e8
        d09714c4 cf8d3f9c d09714c4 d097146c 00000000 cfd979c0 cf8d3f9c 
cf12df18
        cf8d3f9c d093e6f5 d0971420 cfd979c0 cf8d3f9c d093e5a0 cefbc000 
cf12df18
Call Trace:
  [<c0239f23>] kobject_cleanup+0x83/0x90
  [<c027de8f>] bus_for_each_dev+0x6f/0xc0
  [<d093e6f5>] nodemgr_node_probe+0x55/0x120 [ieee1394]
  [<d093e5a0>] nodemgr_probe_ne_cb+0x0/0x90 [ieee1394]
  [<d093eae8>] nodemgr_host_thread+0x168/0x190 [ieee1394]
  [<d093e980>] nodemgr_host_thread+0x0/0x190 [ieee1394]
  [<c010ac15>] kernel_thread_helper+0x5/0x10

Code:  Bad EIP value.
  <6>e100: Intel(R) PRO/100 Network Driver, 3.0.13_dev
e100: Copyright(c) 1999-2004 Intel Corporation
e100: eth0: e100_probe: addr 0xfd5ff000, irq 19, MAC addr 08:00:09:DC:E1:1A
e100: eth0: e100_watchdog: link up, 100Mbps, full-duplex
process `snmpd' is using obsolete setsockopt SO_BSDCOMPAT
parport0: PC-style at 0x378 [PCSPP]
parport0: cpp_daisy: aa5500ff(38)
parport0: assign_addrs: aa5500ff(38)
parport0: cpp_daisy: aa5500ff(38)
parport0: assign_addrs: aa5500ff(38)
lp0: using parport0 (polling).
pnp: Device 00:01.00 activated.
pnp: Device 00:01.02 activated.


Robert Gadsdon

Andrew Morton wrote:
> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.3-rc2/2.6.3-rc2-mm1/
> 
> 
> - Added the big ISDN update
> 
> - Device Mapper update
> 
> 
> 
> 
> Changes since 2.6.3-rc1-mm1:
> 
> 
>  linus.patch
>  bk-netdev.patch
>  bk-input.patch
>  bk-acpi.patch
>  bk-ieee1394.patch
>  bk-scsi.patch
> 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

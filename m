Subject: Re: slab fragmentation ?
From: Badari Pulavarty <pbadari@us.ibm.com>
In-Reply-To: <4162ECAD.8090403@colorfullife.com>
References: <1096500963.12861.21.camel@dyn318077bld.beaverton.ibm.com>
	 <20040929204143.134154bc.akpm@osdl.org>  <29460000.1096555795@[10.10.2.4]>
	 <1096555693.12861.27.camel@dyn318077bld.beaverton.ibm.com>
	 <415F968B.8000403@colorfullife.com>
	 <1096905099.12861.117.camel@dyn318077bld.beaverton.ibm.com>
	 <41617567.9010507@colorfullife.com>
	 <1096987570.12861.122.camel@dyn318077bld.beaverton.ibm.com>
	 <4162E0AF.4000704@colorfullife.com>
	 <1097000846.12861.143.camel@dyn318077bld.beaverton.ibm.com>
	 <4162ECAD.8090403@colorfullife.com>
Content-Type: text/plain
Message-Id: <1097002074.12861.145.camel@dyn318077bld.beaverton.ibm.com>
Mime-Version: 1.0
Date: 05 Oct 2004 11:47:54 -0700
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Manfred Spraul <manfred@colorfullife.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2004-10-05 at 11:49, Manfred Spraul wrote:
> Badari Pulavarty wrote:
> 
> >>The fix would be simple: kmem_cache_alloc_node must walk through the 
> >>list of partial slabs and check if it finds a slab from the correct 
> >>node. If it does, then just use that slab instead of allocating a new 
> >>one. And statistics must be added to kmem_cache_alloc_node - I forgot 
> >>that when I wrote the function.
> >>    
> >>
> >
> >I will add more debug to find out if this is happening or not.
> >
> >What stats you want me to update in kmem_cache_alloc_node() ?
> >
> >  
> >
> I would just add a printk to confirm our suspicion. 
> "kmem_cache_alloc_node called" + dump_stack(). I always use that 
> approach, thus I forgot to add proper statistics.

Yep. 

 [<c01078c2>] dump_stack+0x17/0x1b
 [<c0143323>] kmem_cache_alloc_node+0x181/0x186
 [<c0143462>] __alloc_percpu+0x65/0xb9
 [<c023c03e>] alloc_disk+0x45/0xc8
 [<c027fcb5>] sd_probe+0x89/0x341
 [<c0232d64>] bus_match+0x35/0x5e
 [<c0232dcc>] device_attach+0x3f/0x8f
 [<c023305e>] bus_add_device+0x68/0xab
 [<c0231ff8>] device_add+0x94/0x12a
 [<c027ccbe>] scsi_sysfs_add_sdev+0x3e/0x1bf
 [<c027b871>] scsi_add_lun+0x2d9/0x378
 [<c027b9b4>] scsi_probe_and_add_lun+0xa4/0x1d1
 [<c027bed3>] scsi_report_lun_scan+0x2a0/0x3c2
 [<c027c1af>] scsi_scan_target+0xc2/0xeb
 [<c027c23c>] scsi_scan_channel+0x64/0x77
 [<c027c314>] scsi_scan_host_selected+0xc5/0xff
 [<c027c372>] scsi_scan_host+0x24/0x28
 [<f8833654>] sdebug_driver_probe+0x94/0xb8 [scsi_debug]
 [<c0232d64>] bus_match+0x35/0x5e
 [<c0232dcc>] device_attach+0x3f/0x8f
 [<c023305e>] bus_add_device+0x68/0xab
 [<c0231ff8>] device_add+0x94/0x12a
 [<f883348a>] sdebug_add_adapter+0x124/0x1e7 [scsi_debug]
 [<f88331cc>] sdebug_add_host_store+0x6b/0x9a [scsi_debug]
 [<c0232a7d>] drv_attr_store+0x37/0x39
 [<c018e65b>] flush_write_buffer+0x31/0x3e
 [<c018e6ab>] sysfs_write_file+0x43/0x52
 [<c0157d68>] vfs_write+0xba/0x107
 [<c0157e3d>] sys_write+0x35/0x53
 [<c0106a89>] sysenter_past_esp+0x52/0x71



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

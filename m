Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id DE0A06B00C7
	for <linux-mm@kvack.org>; Tue, 22 Nov 2011 21:03:42 -0500 (EST)
Message-ID: <4ECC54FD.3060504@redhat.com>
Date: Wed, 23 Nov 2011 10:05:49 +0800
From: Dave Young <dyoung@redhat.com>
MIME-Version: 1.0
Subject: Re: BUG:  zonelist->_zonerefs == 0x1c08
References: <4ECB5C80.8080609@redhat.com> <alpine.DEB.2.00.1111220140470.4306@chino.kir.corp.google.com> <20111122152739.GA5663@redhat.com> <4ECC4AF8.4010109@redhat.com>
In-Reply-To: <4ECC4AF8.4010109@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vivek Goyal <vgoyal@redhat.com>
Cc: Jens Axboe <axboe@kernel.dk>, Mike Snitzer <snitzer@redhat.com>, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

On 11/23/2011 09:23 AM, Dave Young wrote:

> On 11/22/2011 11:27 PM, Vivek Goyal wrote:
> 
>> On Tue, Nov 22, 2011 at 02:00:24AM -0800, David Rientjes wrote:
>>> On Tue, 22 Nov 2011, Dave Young wrote:
>>>
>>>> [    0.000000] Linux version 3.2.0-rc2+ (dave@darkstar) (gcc version
>>>> 4.5.2 (GCC) ) #256 SMP
>>>> [    0.000000] Command line: ro root=/dev/mapper/vg_dellper71001-lv_root
>>>> rd_LVM_LV=vg_dellp
>>>> [    0.000000] KERNEL supported cpus:
>>>> [    0.000000]   Intel GenuineIntel
>>>> [    0.000000]   AMD AuthenticAMD
>>>> [    0.000000]   Centaur CentaurHauls
>>>> [    0.000000] BIOS-provided physical RAM map:
>>>> [    0.000000]  BIOS-e820: 0000000000000100 - 00000000000a0000 (usable)
>>>> [    0.000000]  BIOS-e820: 0000000000100000 - 00000000cf379000 (usable)
>>>> [    0.000000]  BIOS-e820: 00000000cf379000 - 00000000cf38f000 (reserved)
>>>> [    0.000000]  BIOS-e820: 00000000cf38f000 - 00000000cf3ce000 (ACPI data)
>>>> [    0.000000]  BIOS-e820: 00000000cf3ce000 - 00000000d0000000 (reserved)
>>>> [    0.000000]  BIOS-e820: 00000000e0000000 - 00000000f0000000 (reserved)
>>>> [    0.000000]  BIOS-e820: 00000000fe000000 - 0000000100000000 (reserved)
>>>> [    0.000000]  BIOS-e820: 0000000100000000 - 0000000630000000 (usable)
>>>> [    0.000000] last_pfn = 0x630000 max_arch_pfn = 0x400000000
>>>> [    0.000000] NX (Execute Disable) protection: active
>>>> [    0.000000] user-defined physical RAM map:
>>>> [    0.000000]  user: 0000000000000000 - 0000000000010000 (reserved)
>>>> [    0.000000]  user: 0000000000010000 - 00000000000a0000 (usable)
>>>> [    0.000000]  user: 0000000003090000 - 000000000affb000 (usable)
>>>> [    0.000000]  user: 00000000cf379000 - 00000000cf38f000 (reserved)
>>>> [    0.000000]  user: 00000000cf38f000 - 00000000cf3ce000 (ACPI data)
>>>> [    0.000000]  user: 00000000cf3ce000 - 00000000d0000000 (reserved)
>>>> [    0.000000]  user: 00000000e0000000 - 00000000f0000000 (reserved)
>>>> [    0.000000]  user: 00000000fe000000 - 0000000100000000 (reserved)
>>>> [    0.000000] DMI 2.6 present.
>>>> [    0.000000] No AGP bridge found
>>>> [    0.000000] last_pfn = 0xaffb max_arch_pfn = 0x400000000
>>>> [    0.000000] x86 PAT enabled: cpu 0, old 0x7010600070106, new
>>>> 0x7010600070106
>>>> [    0.000000] found SMP MP-table at [ffff8800000fe710] fe710
>>>> [    0.000000] Using GB pages for direct mapping
>>>> [    0.000000] init_memory_mapping: 0000000000000000-000000000affb000
>>>> [    0.000000] RAMDISK: 0ac79000 - 0afef000
>>>> [    0.000000] ACPI: RSDP 00000000000f1240 00024 (v02 DELL  )
>>>> [    0.000000] ACPI: XSDT 00000000000f1344 0009C (v01 DELL   PE_SC3
>>>> 00000001 DELL 0000000
>>>> [    0.000000] ACPI: FACP 00000000cf3b3f9c 000F4 (v03 DELL   PE_SC3
>>>> 00000001 DELL 0000000
>>>> [    0.000000] ACPI: DSDT 00000000cf38f000 03D72 (v01 DELL   PE_SC3
>>>> 00000001 INTL 2005062
>>>> [    0.000000] ACPI: FACS 00000000cf3b6000 00040
>>>> [    0.000000] ACPI: APIC 00000000cf3b3478 0015E (v01 DELL   PE_SC3
>>>> 00000001 DELL 0000000
>>>> [    0.000000] ACPI: SPCR 00000000cf3b35d8 00050 (v01 DELL   PE_SC3
>>>> 00000001 DELL 0000000
>>>> [    0.000000] ACPI: HPET 00000000cf3b362c 00038 (v01 DELL   PE_SC3
>>>> 00000001 DELL 0000000
>>>> [    0.000000] ACPI: DMAR 00000000cf3b3668 001C0 (v01 DELL   PE_SC3
>>>> 00000001 DELL 0000000
>>>> [    0.000000] ACPI: MCFG 00000000cf3b38c4 0003C (v01 DELL   PE_SC3
>>>> 00000001 DELL 0000000
>>>> [    0.000000] ACPI: WD__ 00000000cf3b3904 00134 (v01 DELL   PE_SC3
>>>> 00000001 DELL 0000000
>>>> [    0.000000] ACPI: SLIC 00000000cf3b3a3c 00176 (v01 DELL   PE_SC3
>>>> 00000001 DELL 0000000
>>>> [    0.000000] ACPI: ERST 00000000cf392ef4 00270 (v01 DELL   PE_SC3
>>>> 00000001 DELL 0000000
>>>> [    0.000000] ACPI: HEST 00000000cf393164 003A8 (v01 DELL   PE_SC3
>>>> 00000001 DELL 0000000
>>>> [    0.000000] ACPI: BERT 00000000cf392d74 00030 (v01 DELL   PE_SC3
>>>> 00000001 DELL 0000000
>>>> [    0.000000] ACPI: EINJ 00000000cf392da4 00150 (v01 DELL   PE_SC3
>>>> 00000001 DELL 0000000
>>>> [    0.000000] ACPI: SRAT 00000000cf3b3bc0 00370 (v01 DELL   PE_SC3
>>>> 00000001 DELL 0000000
>>>> [    0.000000] ACPI: TCPA 00000000cf3b3f34 00064 (v02 DELL   PE_SC3
>>>> 00000001 DELL 0000000
>>>> [    0.000000] ACPI: SSDT 00000000cf3b7000 02A4C (v01  INTEL PPM RCM
>>>> 80000001 INTL 2006110
>>>> [    0.000000] SRAT: PXM 1 -> APIC 0x20 -> Node 0
>>>> [    0.000000] SRAT: PXM 2 -> APIC 0x00 -> Node 1
>>>> [    0.000000] SRAT: PXM 1 -> APIC 0x34 -> Node 0
>>>> [    0.000000] SRAT: PXM 2 -> APIC 0x14 -> Node 1
>>>> [    0.000000] SRAT: PXM 1 -> APIC 0x21 -> Node 0
>>>> [    0.000000] SRAT: PXM 2 -> APIC 0x01 -> Node 1
>>>> [    0.000000] SRAT: PXM 1 -> APIC 0x35 -> Node 0
>>>> [    0.000000] SRAT: PXM 2 -> APIC 0x15 -> Node 1
>>>> [    0.000000] SRAT: Node 1 PXM 2 0-d0000000
>>>> [    0.000000] SRAT: Node 1 PXM 2 100000000-330000000
>>>> [    0.000000] SRAT: Node 0 PXM 1 330000000-630000000
>>>> [    0.000000] Initmem setup node 1 0000000000000000-000000000affb000
>>>> [    0.000000]   NODE_DATA [000000000aff6000 - 000000000affafff]
>>>
>>> blk_throtl_init() is trying to allocate on a specific node and it appears 
>>> like its zonelists were never built successfully.  I'd guess it's trying 
>>> to allocate on node 0 since it's not onlined above, probably because this 
>>> is the crashkernel.  Your SRAT maps two different nodes but it's only 
>>> onlining node 1 and not node 0.
>>>
>>> The problem is that blk_alloc_queue_node() allocs the requeue_queue with 
>>> __GFP_ZERO, which zeros it and never initialized the node field so it 
>>> remains zero.  blk_throtl_init() then calls kzalloc_node() on node 0 which 
>>> doesn't have initialized zonelists.
>>>
>>> Maybe try this?
>>>
>>> diff --git a/block/blk-core.c b/block/blk-core.c
>>> index ea70e6c..99c1881 100644
>>> --- a/block/blk-core.c
>>> +++ b/block/blk-core.c
>>> @@ -467,6 +467,7 @@ struct request_queue *blk_alloc_queue_node(gfp_t gfp_mask, int node_id)
>>>  	q->backing_dev_info.state = 0;
>>>  	q->backing_dev_info.capabilities = BDI_CAP_MAP_COPY;
>>>  	q->backing_dev_info.name = "block";
>>> +	q->node = node_id;
>>>  
>>
>> Storing q->node info at queue allocation time makes sense to me. In fact
>> it might make sense to clean it up from blk_init_allocated_queue_node
>> and assume that passed queue has queue->node set at the allocation time.
>>
>> CCing Mike Snitzer who introduced blk_init_allocated_queue_node(). Mike
>> what do you think. I am not sure it makes sense to pass in nodeid, both
>> at queue allocation and queue initialization time. To me, it should make
>> more sense to allocate the queue at one node and that becomes the default
>> node for reset of the initialization.
>>
>> I am wondering why node0 is not coming up in kdump kernel. Assuming that
>> you must have reserved memory in node0 in first kernel, shouldn't it come
>> up in second kernel?
> 
> 
> Vivek, the reserved memory stay in node1 in first kernel also:
> see following kmsg:
> 	SRAT: Node 1 PXM 2 0-d0000000
> 	SRAT: Node 1 PXM 2 100000000-330000000
> 	SRAT: Node 0 PXM 1 330000000-630000000>


And this line:
[    0.000000] Reserving 128MB of memory at 48MB for crashkernel (System
RAM: 25344MB)

> 
>> Thanks
>> Vivek
>>
>> _______________________________________________
>> kexec mailing list
>> kexec@lists.infradead.org
>> http://lists.infradead.org/mailman/listinfo/kexec
> 
> 
> 



-- 
Thanks
Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

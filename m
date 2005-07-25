Date: Mon, 25 Jul 2005 15:41:27 -0700
From: "Martin J. Bligh" <mbligh@mbligh.org>
Reply-To: "Martin J. Bligh" <mbligh@mbligh.org>
Subject: Re: Question about OOM-Killer
Message-ID: <73740000.1122331287@flay>
In-Reply-To: <20050725121130.5fed7286.washer@trlp.com>
References: <20050718122101.751125ef.washer@trlp.com><20050718123650.01a49f31.washer@trlp.com><20050723130048.GA16460@dmt.cnet> <20050725121130.5fed7286.washer@trlp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: James Washer <washer@trlp.com>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: linux-mm@kvack.org, ak@muc.de
List-ID: <linux-mm.kvack.org>

Jim, does seem bloody silly to be shooting stuff here, and is
probably simple to fix ... however, would be useful to see where
the DMA allocs are coming from as well, any chance you could dump
a stack backtrace in __alloc_pages when we spec a mask for DMA alloc?

M.

--On Monday, July 25, 2005 12:11:30 -0700 James Washer <washer@trlp.com> wrote:

> Pretty typical message here...
> Jul  6 17:31:27 p6 kernel: oom-killer: gfp_mask=0xd1
> Jul  6 17:31:27 p6 kernel: Node 0 DMA per-cpu:
> Jul  6 17:31:27 p6 kernel: cpu 0 hot: low 2, high 6, batch 1
> Jul  6 17:31:27 p6 kernel: cpu 0 cold: low 0, high 2, batch 1 
> Jul  6 17:31:27 p6 kernel: cpu 1 hot: low 2, high 6, batch 1
> Jul  6 17:31:27 p6 kernel: cpu 1 cold: low 0, high 2, batch 1 
> Jul  6 17:31:27 p6 kernel: Node 0 Normal per-cpu:
> Jul  6 17:31:27 p6 kernel: cpu 0 hot: low 32, high 96, batch 16
> Jul  6 17:31:27 p6 kernel: cpu 0 cold: low 0, high 32, batch 16
> Jul  6 17:31:27 p6 kernel: cpu 1 hot: low 32, high 96, batch 16
> Jul  6 17:31:27 p6 kernel: cpu 1 cold: low 0, high 32, batch 16
> Jul  6 17:31:27 p6 kernel: Node 0 HighMem per-cpu: empty
> Jul  6 17:31:27 p6 kernel: 
> Jul  6 17:31:31 p6 gconfd (washer-7174): SIGHUP received, reloading all databases
> Jul  6 17:31:37 p6 kernel: Free pages:       16236kB (0kB HighMem)
> Jul  6 17:31:38 p6 su(pam_unix)[9041]: session closed for user root
> Jul  6 17:31:38 p6 su(pam_unix)[10645]: session closed for user root
> Jul  6 17:31:38 p6 su(pam_unix)[8044]: session closed for user root
> Jul  6 17:31:38 p6 su(pam_unix)[7228]: session closed for user root
> Jul  6 17:31:38 p6 su(pam_unix)[16136]: session closed for user root
> Jul  6 17:31:48 p6 gconfd (washer-7174): Resolved address "xml:readonly:/etc/gconf/gconf.xml.mandatory" to a read-only configuration source at position 0
> Jul  6 17:31:49 p6 kernel: Active:596167 inactive:854867 dirty:624740 writeback:0 unstable:0 free:4059 slab:52688 mapped:595231 pagetables:4862
> Jul  6 17:32:00 p6 gconfd (washer-7174): Resolved address "xml:readwrite:/home/washer/.gconf" to a writable configuration source at position 1
> Jul  6 17:32:02 p6 kernel: Node 0 DMA free:20kB min:24kB low:28kB high:36kB active:0kB inactive:0kB present:16384kB pages_scanned:1 all_unreclaimable? yes
> Jul  6 17:32:04 p6 gconfd (washer-7174): Resolved address "xml:readonly:/etc/gconf/gconf.xml.defaults" to a read-only configuration source at position 2
> Jul  6 17:32:06 p6 kernel: lowmem_reserve[]: 0 7152 7152
> Jul  6 17:32:11 p6 kernel: Node 0 Normal free:16216kB min:10808kB low:13508kB high:16212kB active:2384668kB inactive:3419468kB present:7323648kB pages_scanned:0 all_unreclaimable? no
> Jul  6 17:32:13 p6 kernel: lowmem_reserve[]: 0 0 0
> Jul  6 17:32:13 p6 kernel: Node 0 HighMem free:0kB min:128kB low:160kB high:192kB active:0kB inactive:0kB present:0kB pages_scanned:0 all_unreclaimable? no
> Jul  6 17:32:13 p6 kernel: lowmem_reserve[]: 0 0 0 
> Jul  6 17:32:13 p6 kernel: Node 0 DMA: 1*4kB 0*8kB 1*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 20kB
> Jul  6 17:32:13 p6 kernel: Node 0 Normal: 34*4kB 192*8kB 53*16kB 92*32kB 2*64kB 1*128kB 1*256kB 0*512kB 0*1024kB 1*2048kB 2*4096kB = 16216kB
> Jul  6 17:32:13 p6 kernel: Node 0 HighMem: empty
> Jul  6 17:32:13 p6 kernel: Swap cache: add 48, delete 48, find 0/0, race 0+0
> Jul  6 17:32:13 p6 kernel: Free swap  = 8385728kB
> Jul  6 17:32:13 p6 kernel: Total swap = 8385920kB
> Jul  6 17:32:13 p6 kernel: Out of Memory: Killed process 10475 (firefox-bin).
> 
> 
> On Sat, 23 Jul 2005 10:00:48 -0300
> Marcelo Tosatti <marcelo.tosatti@cyclades.com> wrote:
> 
>> 
>> James,
>> 
>> Can you send the OOM killer output? 
>> 
>> I dont know which devices part of an x86-64 system should 
>> be limited to 16Mb of physical addressing. Andi? 
>> 
>> I don't think that any devices should have 16MB limitation
>> 
>> On Mon, Jul 18, 2005 at 12:36:50PM -0700, James Washer wrote:
>> > Sorry, I should have added... 
>> > 	2.6.11.10, 
>> > 	x86-64 dual proc (Intel Xeon 3.4GHz)
>> > 	6GiB ram
>> > 	Intel Corporation 82801EB (ICH5) SATA Controller (rev 0)
>> > 	Host: scsi0 Channel: 00 Id: 00 Lun: 00
>> > 		Vendor: ATA      Model: Maxtor 6Y160M0   Rev: YAR5
>> > 		Type:   Direct-Access                    ANSI SCSI revision: 05
>> > 	Host: scsi0 Channel: 00 Id: 01 Lun: 00
>> > 		Vendor: ATA      Model: Maxtor 7Y250M0   Rev: YAR5
>> > 		Type:   Direct-Access                    ANSI SCSI revision: 05
>> > 
>> > 
>> > On Mon, 18 Jul 2005 12:21:01 -0700
>> > James Washer <washer@trlp.com> wrote:
>> > 
>> > > I'm chasing down a system problem where the DMA memory (x86-64, god knows why it is using DMA memory)
>> > drops below the minimum, and the OOM-Killer is fired off.
>> > > 
>> > > It just strikes me odd that the OOM-Killer would be called at all for DMA memory. 
>> > What's the chance of regaining DMA memory by killing user land processes?
>> > > 
>> > > I'll admit, I know very little about linux VM, so perhaps I'm missing how oom killing can be helpful here.  
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

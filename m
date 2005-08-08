Date: Mon, 8 Aug 2005 14:41:25 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [Bugme-new] [Bug 5026] New: Kernel doesn't handle Memory Hole
 Remapping without a mem= option
Message-Id: <20050808144125.263d6147.akpm@osdl.org>
In-Reply-To: <200508081950.j78JoSKq004028@fire-1.osdl.org>
References: <200508081950.j78JoSKq004028@fire-1.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, "bugme-daemon@kernel-bugs.osdl.org" <bugme-daemon@kernel-bugs.osdl.org>
List-ID: <linux-mm.kvack.org>

bugme-daemon@kernel-bugs.osdl.org wrote:
>
> http://bugzilla.kernel.org/show_bug.cgi?id=5026
> 
>            Summary: Kernel doesn't handle Memory Hole Remapping without a
>                     mem= option
>     Kernel Version: All
>             Status: NEW
>           Severity: normal
>              Owner: akpm@osdl.org
>          Submitter: bjrosen@polybus.com
> 
> 
> Most recent kernel where this bug did not occur:2.6.13.rc3
> Distribution:Fedora Core 3
> Hardware Environment:Athlon 64 X2 4400+, MSI K8N Neo 4 (Nforce 4), 4G DDR
> Software Environment:
> Problem Description:
> 
> On Athlon 64 systems with Nforce chipsets the chipset is mapped into the upper
> part of the first 4G of physical memory space which means that the BIOS can't
> map 4G into the lower 4G of space. The BIOS on the MSI K8N motherboards (I have
> the Neo2 and the Neo4, both do the same thing) has an option called Memory Hole
> Remapping. When enabled the BIOS sees all 4G. However the Linux kernel will
> panic with this option unless there is a mem= boot option. With mem=5G the
> kernel will see all 4G of memory. With mem=4G it sees only 3G. I've tried this
> with both 32 bit highmem and 64 bit kernels, the behavior is identical. With the
> following line in grub.conf the kernel boots fine and recognizes all 4G of RAM.
> 
> kernel /boot/vmlinuz-2.6.11.12BigMem ro root=LABEL=/ mem=5G rhgb quiet
> 
> This is a bit of a kludge, the kernel ought to be able to handle memory hoisting
> automatically.
> 
> Here is the dmseg info from my system,
> Linux version 2.6.11.12BigMem (root@nimitz.bjrosen.com) (gcc version 3.4.4
> 20050721 (Red Hat 3.4.4-2)) #2 SMP Sat Aug 6 09:20:51 EDT 2005
> BIOS-provided physical RAM map:
>  BIOS-e820: 0000000000000000 - 000000000009f400 (usable)
>  BIOS-e820: 000000000009f400 - 00000000000a0000 (reserved)
>  BIOS-e820: 00000000000f0000 - 0000000000100000 (reserved)
>  BIOS-e820: 0000000000100000 - 00000000bfff0000 (usable)
>  BIOS-e820: 00000000bfff0000 - 00000000bfff3000 (ACPI NVS)
>  BIOS-e820: 00000000bfff3000 - 00000000c0000000 (ACPI data)
>  BIOS-e820: 00000000e0000000 - 00000000f0000000 (reserved)
>  BIOS-e820: 00000000fec00000 - 0000000100000000 (reserved)
>  BIOS-e820: 0000000100000000 - 0000000140000000 (usable)
> user-defined physical RAM map:
>  user: 0000000000000000 - 000000000009f400 (usable)
>  user: 000000000009f400 - 00000000000a0000 (reserved)
>  user: 00000000000f0000 - 0000000000100000 (reserved)
>  user: 0000000000100000 - 00000000bfff0000 (usable)
>  user: 00000000bfff0000 - 00000000bfff3000 (ACPI NVS)
>  user: 00000000bfff3000 - 00000000c0000000 (ACPI data)
>  user: 00000000e0000000 - 00000000f0000000 (reserved)
>  user: 00000000fec00000 - 0000000100000000 (reserved)
>  user: 0000000100000000 - 0000000140000000 (usable)
> 4224MB HIGHMEM available.
> 896MB LOWMEM available.
> found SMP MP-table at 000f5300
> NX (Execute Disable) protection: active
> On node 0 totalpages: 1310720
>   DMA zone: 4096 pages, LIFO batch:1
>   Normal zone: 225280 pages, LIFO batch:16
>   HighMem zone: 1081344 pages, LIFO batch:16
> 

Does someone have time to look into this please?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

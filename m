Received: from 192.168.57.15 (a3 [192.168.57.23])
	by WS0005.indiatimes.com (8.9.3/8.9.3) with SMTP id WAA21157
	for <linux-mm@kvack.org>; Tue, 12 Feb 2002 22:38:27 +0530
From: "prodyuth" <prodyuth@indiatimes.com>
Message-Id: <200202121708.WAA21157@WS0005.indiatimes.com>
Reply-To: "prodyuth" <prodyuth@indiatimes.com>
Subject: Accessing memory above kernel load address
Date: Tue, 12 Feb 2002 22:35:33 +0530
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi all,

I am running linux on a MIPS board that has 16Mb of memory. The memory map starts from 0x8000 0000 to 0x8100 0000 ( 16MB . This space is KSEG0 in MIPS terminology)

I use a bootloader to bring up the linux kernel. The boot loader sits in address 0x8020 0000 to 0x8040 0000. The bootloader loads the Linux Kernel in physical address 0x8090 0000.

I have setup the RAM space available for Linux kernel as 16MB, starting from PAGE_OFFSET (0x8000 0000). But since the kernel is loaded at 0x8090 0000 it is unable to access the region which the bootloader was using earlier. (0x8000 0000 to 0x8090 0000) after the Linux kernel is up and running. How do I access that region?

I tried to open ("/dev/kmem") after the Linux kernel came up. When I did a read on /dev/kmem after opening it, the linux kernel just hanged.

When I did an lseek to 0x200000 and then tried to read /dev/kmem, the kernel crashed. 

I did an lseek to 0x200000 because I want to access the memory region starting from 0x80200000.

The memory map is drawn here for clarification.



-----------------------  <--- Address 0x8000 0000 

|   Bootloader memory |
-----------------------  <--- Address 0x8090 0000

| Linux kernel memory |

---------------------- <---  Address 0x8100 0000



I cannot change the memory map.



Any pointers to help me will be greatly appreciated.



Thanks & regards,

Prodyut.




Get Your Private, Free E-mail from Indiatimes at http://email.indiatimes.com

 Buy Music, Video, CD-ROM, Audio-Books and Music Accessories from http://www.planetm.co.in

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

Message-ID: <3DAC9CD31458D411BCE700D0B75D0A13066DFCD0@ES09-HOU.bmc.com>
From: "Patwardhan, Aniruddha" <Aniruddha_Patwardhan@bmc.com>
Subject: RE: questions on swapping
Date: Mon, 28 Apr 2003 02:32:58 -0500
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: 'Heerappa Hunje' <hunjeh@celetron.com>, linux-mm@kvack.org, kernelnewbies@nl.linux.org
List-ID: <linux-mm.kvack.org>

Hi Heerappa,

I will suggest you try googling before you put question on the list.
anyway find comments in <<...>>

Thanks & Regards,
Aniruddha
 -------------------------------------
| Aniruddha S. Patwardhan             |
| BMC Software India Pvt. Ltd.        |
| Email: aniruddha_patwardhan@bmc.com |
| Phone: +91-20-4035129               |
| www : http://aniruddha.talk.to      |
 -------------------------------------

-----Original Message-----
From: Heerappa Hunje [mailto:hunjeh@celetron.com]
Sent: Monday, April 28, 2003 12:46 PM
To: linux-mm@kvack.org; kernelnewbies@nl.linux.org
Subject: questions on swapping


Dear sir,

1. I have problem in locating the source code of linux operating system
because i dont know in which path it is kept. Pls suggest me the pathname.
<<
Linux source code is generally located in /usr/src/linux<version>
>>

2. let me know the different ways to connect the device drivers module to
the kernel.
<<
You need to compile the device driver module with required flags and need to
insert the module in kernel using insmod
>>

3. let me know where actually the space for SWAPPING, BUFFERS  are
allocated. i mean whether they are in RAM Memory or Hard disk drive.
<<
While configuring the system you generally create a separate partition for
swap device. We can also configure some file as a swap space. Generally swap
space is located on disk bcoz the entire purpose of swap is to extend
physical memory.

Any way technically you can even configure ramdisk and make it swap
partition.
>>

Thanks in advance for the help.


Thanks and regards
Heerappa.





--
Kernelnewbies: Help each other learn about the Linux kernel.
Archive:       http://mail.nl.linux.org/kernelnewbies/
FAQ:           http://kernelnewbies.org/faq/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

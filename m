Received: from smtp.zarkov.es (212.106.196.188) by smtp1.jazzfree.com (NPlex 4.0.054)
        id 38B6F406001DA1C3 for linux-mm@kvack.org; Sun, 26 Mar 2000 15:07:19 +0200
Received: from jazzfree.com (really [127.0.0.1]) by zarkov.jazzfree.com
	via in.smtpd with esmtp (ident rfv using rfc1413)
	id <m12ZCkp-000uHfC@smtp.zarkov.es> (Debian Smail3.2.0.102)
	for <linux-mm@kvack.org>; Sun, 26 Mar 2000 15:06:55 +0200 (CEST)
Message-ID: <38DDFD59.D000C569@jazzfree.com>
Date: Sun, 26 Mar 2000 14:06:49 +0200
From: Rodrigo Fernandez-Vizarra Bonet <rodrigofv@jazzfree.com>
MIME-Version: 1.0
Subject: Memory management question
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

I'm developing a linux module and I'm having some trouble with the
memory management in Linux.

Basically, what I want to do is to reserve some physical pages from the
kernel when I install the module (insmod module.o), and when a process
requests them (with mmap), I want to map that pages in the process
virtual memory area.

That's what I'm doing now.
1.- In the kernel I get some physical pages with get_free_page or with
__get_free_page.
2.- I create a device entry en /dev/ called pmm with
module_register_chrdev() with my own version of mmap.
3.- This mmap function uses the function remap_page_range() to map one
of the physical pages into the calling process virtual memory. Of course
the calling process must explicitly call mmap on the new device created
before.
4.- In the kernel space I store some information in that pages.
5.- In the user space process I mmap the device and read from it, but I
can not get the information that I stored there :-(


It's not working, and I can't understand why. When the process makes an
mmap on the device it doesn't complain, but the resulting mapping is not
correct, because I can't access the information that is contained in the
physical page.

If any of you can help me It would be apreciated,

thank you very much in advantage.

Best regards,
Rodrigo

-- 
Rodrigo Fernandez-Vizarra Bonet
    e-mail: rodrigofv@jazzfree.com

You still can avoid the GATES of hell, USE LINUX !!!
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

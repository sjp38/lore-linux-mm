Message-ID: <20000820171034.21395.qmail@web6405.mail.yahoo.com>
Date: Sun, 20 Aug 2000 10:10:34 -0700 (PDT)
From: Ramesh Panuganty <rameshpanuganty@yahoo.com>
Subject: memory file system on linux
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

I am new to this group and came here while looking for
a specific information. Can someone help me in getting
the information (please reply to me directly).

Are there any memory file systems on linux with which
I can maitain the entire file system on RAM?
    - will /dev/ram come to of any help for me?
    - I had read about something like 'tmpfs' on SunOS
which is a virtual filesystem that is entirely
resident in the memory (probably shares the space with
swap)

Actually, I will tell you what I am looking for...

I have a 32MB IDE-disc and a 64MB RAM on my machine.
But these small IDE-discs support very limited number
of I/O Operations in their life time. Hence to limit
the I/O, I want to keep the 32MB file system itself on
RAM and do a read-write only once during bootup and
shutdown.

Is there anyway, I can achieve this?

__________________________________________________
Do You Yahoo!?
Yahoo! Mail ? Free email you can access from anywhere!
http://mail.yahoo.com/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

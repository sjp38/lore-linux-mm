Message-ID: <20020102222026.69416.qmail@web12304.mail.yahoo.com>
Date: Wed, 2 Jan 2002 14:20:26 -0800 (PST)
From: Ravi K <kravi26@yahoo.com>
Subject: Maximum physical memory on i386 platform
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kernelnewbies@nl.linux.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,
  The configuration help for HIGHMEM feature on i386
platform states that 'Linux can use up to 64 Gigabytes
of physical memory on x86 systems'. I see a problem
with this:
 - page structures needed to support 64GB would take
up 1GB memory (64 bytes per page of size 4k) 
 - but the kernel can only use 896MB memory, unless
PAGE_OFFSET is changed to a lower value
 - enabling 64GB support does not automatically change
the value of PAGE_OFFSET
   So how are the page structures created if a machine
has 64GB memory? Or is it necessary to change 
PAGE_OFFSET (to 0x80000000) in such a configuration?

Thanks,
Ravi.

__________________________________________________
Do You Yahoo!?
Send your FREE holiday greetings online!
http://greetings.yahoo.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

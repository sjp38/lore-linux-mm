From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <199909232109.OAA13866@google.engr.sgi.com>
Subject: syslinux-1.43 bug [and possible PATCH]
Date: Thu, 23 Sep 1999 14:09:58 -0700 (PDT)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: syslinux@linux.kernel.org, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
Cc: Kanoj Sarcar <kanoj@google.engr.sgi.com>
List-ID: <linux-mm.kvack.org>

I have a possible problem to report with syslinux, and a suggested
fix. Please send me comments and feedback at kanoj@engr.sgi.com, 
since I am not subscribed to the syslinux or kernel lists.

While installing linux (RedHat6.0, SuSe, Mandrake etc) on a ia32
Compaq box with 1.5Gb memory, I have observed kernel panics from 
mount_root. On further investigation, syslinux decides to put initrd 
at a high physical address, which the Linux kernel, compiled with 
PAGE_OFFSET=0xc0000000 can not access. The kernel can access at
the most physical address 0x3c000000, whereas syslinux/ldlinux.asm
can put initrd as high as HIGHMEM_MAX=0x3f000000. This leads
setup_arch() to decide it can not use initrd, thus causing the
kernel panic. 

The easy fix to me seems to be to change HIGHMEM_MAX in
syslinux/ldlinux.asm to 0x3c000000. In fact, I have verified on
a couple of machines that this will let the installation proceed.

Have other people run into this problem and worked around it some
other way? (One way would be to specify mem= at the boot: prompt
from syslinux. Yet another way seems to be to specify mem= in
the syslinux.cfg file. Changing HIGHMEM_MAX seems to be the cleanest,
although I am not sure whether this will impact the capability of
syslinux to install other os'es).

Thanks.

Kanoj
kanoj@engr.sgi.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/

Message-Id: <4.3.2.7.0.20000822155755.00aa3e00@192.168.1.9>
Date: Tue, 22 Aug 2000 16:02:51 +0530
From: Santosh Eraniose <santosh@sony.co.in>
Subject: Memory partitioning
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux-MM@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,
Is it possible to partition the MMU such that multiple OS
can run on the same platform.
In all examples I see like MKLinux , the mem mgmt of Linux is mapped to the
underlying Mach kernel.
The other extreme is as in RTAI (Real time App Interface), where the MMU is 
handled by linux, but the
scheduling is done by RTAI.

Thanks
Santosh Eraniose
-----------------------------------------------
Member Technical
Sony Software Architecture Lab
Bangalore
-----------------------------------------------

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

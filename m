Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id UAA26652
	for <linux-mm@kvack.org>; Fri, 7 Mar 2003 20:57:26 -0800 (PST)
Date: Fri, 7 Mar 2003 20:57:41 -0800
From: Andrew Morton <akpm@digeo.com>
Subject: 2.5.64-mm3
Message-Id: <20030307205741.3eb7d5b3.akpm@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

http://www.kernel.org/pub/linux/kernel/people/akpm/patches/2.5/2.5.64/2.5.64-mm3/


The mistaken reversion of the CPU scheduler changes made -mm2 rather
pointless.  We want to get this tested.



Since 2.5.64-mm2:


-pirq_enable_irq-warning-fix.patch

 Merged

+scheduler-tunables-fix.patch

 Put the correct CPU scheduler tunables in place

+show_interrupts-fixes.patch

 Avod oops in /proc/interrupts handler

+kernel-flag-fix.patch

 Compilation fix

+larger-proc-interrupts-buffer.patch

 Fix /proc/interrupts truncation on large machines


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>

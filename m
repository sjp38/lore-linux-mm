Content-Type: text/plain;
  charset="iso-8859-1"
From: Daniele Bellucci <bellucda@tiscali.it>
Subject: Re: 2.5.69-mm9
Date: Mon, 26 May 2003 20:30:23 +0200
References: <20030525042759.6edacd62.akpm@digeo.com>
In-Reply-To: <20030525042759.6edacd62.akpm@digeo.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8BIT
Message-Id: <200305262030.23526.bellucda@tiscali.it>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

fixed missing sys_kexec_load entry in syscall table (i386 only).

--- linux-2.5.69-mm9/arch/i386/kernel/entry.S   2003-05-26 13:31:02.000000000 +0200
+++ linux-2.5.69-mm9-my/arch/i386/kernel/entry.S        2003-05-27 20:16:11.000000000 +0200
@@ -892,6 +892,6 @@
        .long sys_clock_getres
        .long sys_clock_nanosleep
        .long sys_mknod64
-
+       .long sys_kexec_load

 nr_syscalls=(.-sys_call_table)/4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

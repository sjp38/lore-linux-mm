Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j35MANMj025832
	for <linux-mm@kvack.org>; Tue, 5 Apr 2005 18:10:23 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j35MANBG247318
	for <linux-mm@kvack.org>; Tue, 5 Apr 2005 18:10:23 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11/8.12.11) with ESMTP id j35MAN8g028784
	for <linux-mm@kvack.org>; Tue, 5 Apr 2005 18:10:23 -0400
Message-ID: <4252AAEA.8080202@us.ibm.com>
Date: Tue, 05 Apr 2005 08:12:42 -0700
From: Janet Morgan <janetmor@us.ibm.com>
MIME-Version: 1.0
Subject: 2.6.12-rc2-mm1 compilation failure
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

I ran into this when trying to build 2.6.12-rc2-mm1:

arch/i386/kernel/built-in.o(.init.text+0x161f): In function `setup_arch':
: undefined reference to `acpi_boot_table_init'
arch/i386/kernel/built-in.o(.init.text+0x1624): In function `setup_arch':
: undefined reference to `acpi_boot_init'
make: *** [.tmp_vmlinux1] Error 1

Thanks,
-Janet



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

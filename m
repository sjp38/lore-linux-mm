Received: from geyingan ([10.110.26.103]) by smtp.huawei.com
          (Netscape Messaging Server 4.15) with SMTP id G1GYR200.E01 for
          <linux-mm@kvack.org>; Tue, 26 Sep 2000 08:59:26 +0800
Message-ID: <002001c02756$fe0b5480$671a6e0a@huawei.com.cn>
From: "dony" <dony.he@huawei.com>
Subject: How can I support memory hole in embedded system?
Date: Tue, 26 Sep 2000 09:13:33 +0800
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,

        Now I am working on an embedded project based on Linux(X86). The
motherboard has a memory hole at 15M-16M (PCI==>ISA for FlashRom).
        In 2.4.0 arch/i386/boot/setup.S, It introduces an method known as
"E820" which is said to support memory hole .But it uses "int 15" to get
memory regions  from BIOS which cannot be implemented in my case, since my
motherboard has no BIOS, only BSP instead.
        I think we can modify the memory-mapping to support memory hole, but
I don't know how to do it. In mm/bootmem.c it also mentions it can support
memory hole with no more comments.
        Can you give me some information in detail about this? Thank you
very much.

         dony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

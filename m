Date: Thu, 08 Jun 2000 12:17:17 -0500
From: Timur Tabi <ttabi@interactivesi.com>
Subject: Size of mem_map array?
Message-Id: <20000608174036Z131165-281+93@kanga.kvack.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

I want to write a driver that traverses the mem_map array so that I can better
understand the VM manager.  However, I can't seem to figure out how big mem_map
is. In fact, based on what I've seen, I'm beginning to suspect that mem_map is
not one, contiguous array.  I've scoured the 2.3 kernel source code, but I can't
find anything.  Please help!




--
Timur Tabi - ttabi@interactivesi.com
Interactive Silicon - http://www.interactivesi.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

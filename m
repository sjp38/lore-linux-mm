Received: from shell0.pdx.osdl.net (fw.osdl.org [65.172.181.6])
	by smtp.osdl.org (8.12.8/8.12.8) with ESMTP id j5P1lijA020777
	(version=TLSv1/SSLv3 cipher=EDH-RSA-DES-CBC3-SHA bits=168 verify=NO)
	for <linux-mm@kvack.org>; Fri, 24 Jun 2005 18:47:45 -0700
Received: from bix (shell0.pdx.osdl.net [10.9.0.31])
	by shell0.pdx.osdl.net (8.13.1/8.11.6) with SMTP id j5P1lhlb024641
	for <linux-mm@kvack.org>; Fri, 24 Jun 2005 18:47:44 -0700
Date: Fri, 24 Jun 2005 18:47:21 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Fw: [Bug 4797] New: mmap returns nil when called
Message-Id: <20050624184721.3e819f78.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Anyone interested in taking this on?

Seems that pwc_video_mmap() is working just fine, but it happens to map the
memory buffer to virtual address zero.  According to the manpage, "The
actual place where the object is mapped is returned by mmap, and is never
0.", but I can find no such promise in
http://www.opengroup.org/onlinepubs/009695399/functions/mmap.html.

It's not a good idea to be putting valid stuff at address zero anyway, from
a debuggability POV.



Begin forwarded message:

Date: Fri, 24 Jun 2005 16:46:11 -0700
From: bugme-daemon@kernel-bugs.osdl.org
To: akpm@osdl.org
Subject: [Bug 4797] New: mmap returns nil when called


http://bugzilla.kernel.org/show_bug.cgi?id=4797

            Summary: mmap returns nil when called
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

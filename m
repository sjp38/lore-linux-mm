Date: Wed, 24 Jan 2001 11:48:19 -0600
From: Timur Tabi <ttabi@interactivesi.com>
Subject: Page Attribute Table (PAT) support?
Message-Id: <20010124174538Z131201-223+45@kanga.kvack.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Kernel Mailing list <linux-kernel@vger.kernel.org>, Linux MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

The Page Attribute Table (PAT) is an extension to the x86 page table format
that lets you enable Write Combining on a per-page basis.  Details can be found
in chapter 9.13 of the Intel Architecture Software Developer's Manual, Volume 3
(System Programming).

I noticed that 2.4 doesn't support the Page Attribute Table, despite the fact
that it has a X86_FEATURE_PAT macro in processor.h.  Are there any plans to add
this support?  Ideally, I'd like it to be as a parameter for ioremap.


-- 
Timur Tabi - ttabi@interactivesi.com
Interactive Silicon - http://www.interactivesi.com

When replying to a mailing-list message, please direct the reply to the mailing list only.  Don't send another copy to me.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

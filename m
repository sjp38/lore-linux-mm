Message-ID: <3BCB55DD.60607@zytor.com>
Date: Mon, 15 Oct 2001 14:32:13 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Discardable mappings?
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I have been working on a user-space persistent memory system, and would
like to bring up (again?) the possibility of a "discardable" class of
mappings.  "Discardable" means that the system is free to throw away a
page without storing it to swap, and return SIGSEGV on access, since the
application can regenerate the data on that page if needed.

My personal preference would be if this was a PROT_* flag that could be
used with mprotect(), since my system, and probably most other systems
which need this kind of functionality, use mprotect() on these pages
already, and it'd be nice to avoid Yet Another System Call[TM] in a very
performance-critical part of the system; furthermore, I tend to think of
mprotect() as controlling when to raise SIGSEGV, so it's not *completely*
out of place there...

	-hpa

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

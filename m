Message-ID: <3BCE20DF.6090103@zytor.com>
Date: Wed, 17 Oct 2001 17:22:55 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Under what conditions are VMAs merged?
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux MM mailing list <linux-mm@kvack.org>, torvalds@transmeta.com
List-ID: <linux-mm.kvack.org>

Okay, as part of doing this persistent memory system, I apparently need to
know better when and if VMAs are merged.  The persistent memory obviously
does lots of mprotect() to what is otherwise a large private mapping of a
file (not anonymous.)

In the checkpoint routine I thought doing an mprotect(PROT_READ) on the
entire region as a single system call would coalesce the VMAs, but
apparently that is not the case; after running my standard stress-test
application, /proc/pid/maps show 51635 mappings, most of them contiguous
and otherwise matching the surrounding mappings in every way; a dump of
/proc/pid/maps is at ftp://terminus.zytor.com/pub/hpa/map.gz for the
morbidly curious.

This system is running a stock 2.4.12-ac1; the database file is 1
GB+overhead in size (1,074,008,064 bytes to be exact), it is mapped at
0x5f000000.

Appreciative for any suggestions.

	-hpa

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

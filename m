Message-ID: <3913F0C4.D546D155@gnu.org>
Date: Sat, 06 May 2000 20:15:32 +1000
From: Andrew Clausen <clausen@gnu.org>
MIME-Version: 1.0
Subject: How much to malloc(), without running into swap...?
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: parted@gnu.org
List-ID: <linux-mm.kvack.org>

Hi all, (please cc me)

I'm hacking GNU Parted, which can (amongst other things) resize
file systems.  It's performance is GREATLY improved if large
disk buffers are used, provided it doesn't need to swap to access
the buffers ;-)

So, how can I maximize the buffer sizes, without running into
swap?  Note: I don't want to disable swap, because a certain
(large) minimum is required for storing metadata, etc., so
low-memory machines might want to use a swap (despite it being
slow).

So, I want to know:
(a) how much I can malloc() without swapping
(b) how much I can malloc() with swapping

Also, I presume all IO is going to have to go through the buffer
cache, etc., so having a larger buffers means more consumption
on the kernel side of things.  OTOH, it can probably kick out
old cached data fairly quickly (i.e. data used by other programs)
Any ideas on how to do the calc's?

BTW, is /proc/meminfo a good idea?

Thanks!
Andrew Clausen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

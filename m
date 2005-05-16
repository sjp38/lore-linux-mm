Received: by zproxy.gmail.com with SMTP id 13so1428127nzn
        for <linux-mm@kvack.org>; Mon, 16 May 2005 10:25:33 -0700 (PDT)
Message-ID: <6934efce05051610252b84713f@mail.gmail.com>
Date: Mon, 16 May 2005 10:25:33 -0700
From: Jared Hulbert <jaredeh@gmail.com>
Reply-To: Jared Hulbert <jaredeh@gmail.com>
Subject: /proc/meminfo
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Please have mercy on a linux-mm newbie.  I'd like to understand the
output of /proc/meminfo and /proc/<[0-9]+>/maps.  I want to measure 2
things: First, how much memory in a system is used for code or other
readonly file mmaps or what RAM can be saved by using XIP flash.
Second, at the time a system snapshot is taken how much RAM is
absolutely needed (for example, I assume we could dump caches, flush
buffers, and clean up unused memory.)

Where can I find a good reference to what this all output means?  Are
there other sources of information available?

Here are my assumptions:
# cat /proc/meminfo
MemTotal: = Memory managed by Linux kernel. Total RAM - kernel image.
MemFree: = Memory not allocated.  Not the same as memory availiable to allocate.
Buffers: = ?
Cached: = inode cache
SwapCached: = Used swap space
Active: = Pages allocated by kernel and user processes
Inactive: = Pages allocated but read to be purged
HighTotal: = 2Gig limit stuff
HighFree: =  ""
LowTotal: = ""
LowFree: = ""
SwapTotal: = What is the relationship between this and SwapCached?
SwapFree: =  ""
Dirty: = ?
Writeback: = ?
Slab: = ?
CommitLimit: = ?
Commited_AS: = ?
PageTables: = Memory allocated for use as page tables.
VmallocTotal: = Virtual memory space allocated
VmallocUsed: = ?
VmallocChunk: = ?

# cat /proc/1/maps
08048000-0804E000    r-xp    00000000    75:00    637746    /sbin/init
(readonly, executable mmap of file /sbin/init Probably code)
0804E000-0804F000    rw-p    00000000    75:00    637746    /sbin/init
(readwrite, mmap of file /sbin/init Probably initialized variables
etc)
0804F000-08070000    rw-p    0804F000    00:00    0 (I don't know)

1st column = virtual memory map of map
2nd column = r = read; w = write; x = executable; p =  I don't know
3rd column = I don't know
4th column = size of map (but it often doesn't match the size of column 1)
5th column = name of file
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

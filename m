Subject: kernel BUG at rmap.c:409! with 2.5.31 and akpm patches.
From: Steven Cole <elenstev@mesatop.com>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 19 Aug 2002 14:54:17 -0600
Message-Id: <1029790457.14756.342.camel@spc9.esa.lanl.gov>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: linux-mm@kvack.org, Rik van Riel <riel@conectiva.com.br>, Steven Cole <scole@lanl.gov>
List-ID: <linux-mm.kvack.org>

Here's a new one.

With this patch applied to 2.5.31,
http://www.zip.com.au/~akpm/linux/patches/2.5/2.5.31/stuff-sent-to-linus/everything.gz

I got this BUG:
kernel BUG at rmap.c:409!
while running dbench 40 as a stress test.

The filesystem on which dbench was being run was mounted as ext3.
The box is dual p3, scsi.

This test box got its root filesystem (then ext2) destroyed during
testing last week, so I loaded RH 7.3 on it this morning and made all
partitions ext3.  Now it's ready for more abuse.

Steven


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

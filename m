Received: from d1o43.telia.com (d1o43.telia.com [194.22.195.241])
	by mailf.telia.com (8.9.3/8.9.3) with ESMTP id XAA10132
	for <linux-mm@kvack.org>; Sat, 10 Feb 2001 23:30:06 +0100 (CET)
Received: from dox (t4o43p15.telia.com [194.22.195.195])
	by d1o43.telia.com (8.10.2/8.10.1) with SMTP id f1AMU5B24827
	for <linux-mm@kvack.org>; Sat, 10 Feb 2001 23:30:06 +0100 (CET)
Content-Type: text/plain;
  charset="iso-8859-1"
From: Roger Larsson <roger.larsson@norran.net>
Subject: mmap002 execution time doubled... good or bad sign?
Date: Sat, 10 Feb 2001 23:23:19 +0100
MIME-Version: 1.0
Message-Id: <01021023231906.02374@dox>
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

I have been running various stress tests on disk for some time.
streaming write, copy, read, diff, dbench and mmap002

This is what I have seen:

>From 2.4.0 to 2.4.1 with Marcelos patch write were above 10 MB/s
and read >13 MB/s, dbench > 10 MB/s, mmap took around 2m30.

After 2.4.1-pre8 (did not test anything in between)
Write is at 9-10 [lost 1 MB/s] read is down to 11-12 MB/s [lost 2 MB/s]
dbench > 9 MB/s [one MB/s there too]

But the really strange one - mmap002 now takes > 4m30
Is this expected / good behaviour? mmap002 abuses mmaps...

/RogerL

-- 
Home page:
  none currently
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

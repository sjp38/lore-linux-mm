Message-ID: <3D78E79B.78B202DE@zip.com.au>
Date: Fri, 06 Sep 2002 10:36:27 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: 2.5.33-mm4 filemap_copy_from_user: Unexpected page fault
References: <3D78DD07.E36AE3A9@zip.com.au> <1031331803.2799.178.camel@spc9.esa.lanl.gov>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Steven Cole <elenstev@mesatop.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Steven Cole wrote:
> 
> ...
> > Does this fix?
> ...
> Unfortunately no.

Well, isn't this fun?  umm.  You're _sure_ you ran the right kernel
and such?

Could you send your /proc/mounts, and tell me which of those partitions
you're running the test on?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

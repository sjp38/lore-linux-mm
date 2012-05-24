Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 499BC6B0083
	for <linux-mm@kvack.org>; Thu, 24 May 2012 09:37:34 -0400 (EDT)
Received: by ggm4 with SMTP id 4so10950415ggm.14
        for <linux-mm@kvack.org>; Thu, 24 May 2012 06:37:33 -0700 (PDT)
Date: Thu, 24 May 2012 21:38:21 +0800
From: "majianpeng" <majianpeng@gmail.com>
Subject: the max size of block device on 32bit os,when using do_generic_file_read() proceed.
Message-ID: <201205242138175936268@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm <akpm@linux-foundation.org>, hughd <hughd@google.com>
Cc: linux-mm <linux-mm@kvack.org>

  Hi all:
		I readed a raid5,which size 30T.OS is RHEL6 32bit.
	    I reaed the raid5(as a whole,not parted) and found read address which not i wanted.
		So I tested the newest kernel code,the problem is still.
		I review the code, in function do_generic_file_read()

		index = *ppos >> PAGE_CACHE_SHIFT;
		index is u32.and *ppos is long long.
		So when *ppos is larger than 0xFFFF FFFF *  PAGE_CACHE_SHIFT(16T Byte),then the index is error.

		I wonder this .In 32bit os ,block devices size do not large then 16T,in other words, if block devices larger than 16T,must parted.

																						Thanks all.
 				
--------------
majianpeng
2012-05-24

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

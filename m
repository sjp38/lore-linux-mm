Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 25A2F8D0039
	for <linux-mm@kvack.org>; Wed,  9 Feb 2011 15:00:40 -0500 (EST)
Received: from d01dlp01.pok.ibm.com (d01dlp01.pok.ibm.com [9.56.224.56])
	by e3.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p19Jexru027998
	for <linux-mm@kvack.org>; Wed, 9 Feb 2011 14:41:06 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 113BD728059
	for <linux-mm@kvack.org>; Wed,  9 Feb 2011 15:00:38 -0500 (EST)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p19K0bI5435596
	for <linux-mm@kvack.org>; Wed, 9 Feb 2011 15:00:37 -0500
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p19K0aoO016209
	for <linux-mm@kvack.org>; Wed, 9 Feb 2011 13:00:36 -0700
Date: Wed, 9 Feb 2011 12:00:35 -0800
From: "Darrick J. Wong" <djwong@us.ibm.com>
Subject: [LSF/MM TOPIC] Utilizing T10/DIF in Filesystems
Message-ID: <20110209200035.GG27190@tux1.beaverton.ibm.com>
Reply-To: djwong@us.ibm.com
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

I would like to talk about the status and future direction of T10/DIF support
in the kernel.  Here's something resembling an abstract:

Utilizing T10/DIF in Filesystems

For quite some time, we've been discussing the inclusion of T10/DIF
functionality into the kernel to associate a small amount of checksum/integrity
data with each sector.  Now that actual hardware is appearing on the market, it
is time to take another look at what we can do with this feature.

We'd like to discuss at least a few specific topics:

1. How to resolve the write-after-checksum problem (if we haven't fixed it by then).
2. How do we expose a API that enables userspace to read and write  application
   tags that go with a file's data blocks?
3. How could we make use of the application tag for metadata blocks?
4. A 16-bit application tag is rather small.  What could we do with DIF if that
   tag were bigger, and how could we make that happen?

--D

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

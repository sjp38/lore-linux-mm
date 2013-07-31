Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id E25E56B0034
	for <linux-mm@kvack.org>; Wed, 31 Jul 2013 13:32:09 -0400 (EDT)
Message-ID: <0000014035c96fec-d634905b-2e02-457d-9312-af033a8fe419-000000@email.amazonses.com>
Date: Wed, 31 Jul 2013 17:32:08 +0000
From: Christoph Lameter <cl@linux.com>
Subject: [3.12 0/3] vmstat patches for 3.12 V2
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linuxfoundation.org
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, Joonsoo Kim <js1304@gmail.com>, Alexey Dobriyan <adobriyan@gmail.com>, linux-mm@kvack.org

A set of patches for potential merge in 3.12. 

The main idea here is to reduce the vmstat update overhead
by avoiding interrupt enable/disable and the use of
per cpu atomics.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

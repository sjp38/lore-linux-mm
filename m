Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id DAA11389
	for <linux-mm@kvack.org>; Sun, 29 Dec 2002 03:11:36 -0800 (PST)
Message-ID: <3E0ED867.43FEC596@digeo.com>
Date: Sun, 29 Dec 2002 03:11:35 -0800
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: shpte scheduling-inside-spinlock bug
References: <3E0ECC02.6CEBD613@digeo.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave McCracken <dmccr@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> 
> ...
> umm...  I think we can just turn i_shared_lock into a semaphore.  Nests
> inside mmap_sem.

Yup, that works.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

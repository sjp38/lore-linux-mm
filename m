Received: from imperial.edgeglobal.com (imperial.edgeglobal.com [208.197.226.14])
	by edgeglobal.com (8.9.1/8.9.1) with ESMTP id QAA18117
	for <linux-mm@kvack.org>; Wed, 6 Oct 1999 16:11:50 -0400
Date: Wed, 6 Oct 1999 16:15:59 -0400 (EDT)
From: James Simmons <jsimmons@edgeglobal.com>
Subject: Re: MMIO regions
In-Reply-To: <14328.64984.364562.947945@dukat.scot.redhat.com>
Message-ID: <Pine.LNX.4.10.9910061600520.29637-100000@imperial.edgeglobal.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> Look at http://www.precisioninsight.com/dr/locking.html for a
> description of the cooperative lightweight locking used in the DRI in
> 2.3 kernels to solve this problem.  Basically you have a shared memory
> segment which processes can mmap allowing them to determine if they
> still hold the lock via a simple locked memory operation, and a kernel
> syscall which lets processes which don't have the lock arbitrate for
> access.

I have read those papers. Its not compatible with fbcon. It would require
a massive rewrite which would break everything that works with fbcon. When
people start writing apps using DRI and it locks their machine or damages
the hardware. Well the linux kernel mailing list will have to hear those
complaints. You know people will want to write their own stuff. Of course
precisioninsight should make a licence stating it illegal to write
your own code using their driver or a warning so they don't get their
asses sued. These are the kinds of people who will look for other
solutions like I am. So expect more like me. 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/

Received: from localhost (amitjain@localhost)
	by mailhost.tifr.res.in (8.9.3+3.2W/8.9.3/Debian 8.9.3-21) with ESMTP id QAA29853
	for <linux-mm@kvack.org>; Thu, 27 Dec 2001 16:38:08 +0530
Date: Thu, 27 Dec 2001 16:38:08 +0530 (IST)
From: "Amit S. Jain" <amitjain@tifr.res.in>
Subject: Allocation of kernel memory >128K
In-Reply-To: <Pine.LNX.4.21.0112111531110.5038-100000@mailhost.tifr.res.in>
Message-ID: <Pine.LNX.4.21.0112271634010.29530-100000@mailhost.tifr.res.in>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello everyone,
		I hope u can clear this doubt.This question is a
continuation of the question below which i had posted on this site

On Tue, 11 Dec 2001, Amit S. Jain wrote:

> I have been working on a module in which I copy large amount of data fromn
> the user to the kernel area.To do so I allocate using either kmaaloc or
> vmalloc or  get_free_pages()large amount of memory(in the range of
> MBytes) in the kernel space.However this attempt is not successful.One ofmy 
> colleagues informed me that in the kernel space it is safe not to allocate
> large amount of memory at one time,should be kept upto 30K...is he
> right....could you throw more light on this issue.

  I WANT TO KNOW WHAT AMOUNT OF MEMORY ALLOCATION WILL BE SAFE.i.e. even
if i alloc 30K at a time,will I always get a contiguous memory for that
purpose.??
	Is there a set limit in Linux for the amount of memory we obtain
will always be contiguous or always available??
 
 
Thanking you,
 Amit Jain
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

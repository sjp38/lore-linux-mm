Received: from DreamTime (znmeb2.cust.aracnet.com [216.99.196.116])
	by citrine.spiritone.com (8.12.9/8.12.8) with ESMTP id h8CEVeII029090
	for <linux-mm@kvack.org>; Fri, 12 Sep 2003 07:31:44 -0700
Reply-To: <znmeb@cesmail.net>
From: "M. Edward Borasky" <znmeb@aracnet.com>
Subject: RE: [RFC] Enabling other oom schemes
Date: Fri, 12 Sep 2003 07:30:47 -0700
Message-ID: <001501c3793a$75f15480$74c463d8@plaza.ds.adp.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
In-Reply-To: <3F614C1F.6010802@nortelnetworks.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> -----Original Message-----
> From: owner-linux-mm@kvack.org 
> [mailto:owner-linux-mm@kvack.org] On Behalf Of Chris Friesen
> Sent: Thursday, September 11, 2003 9:31 PM
> To: Rahul Karnik
> Cc: rusty@linux.co.intel.com; riel@conectiva.com.br; 
> linux-mm@kvack.org; linux-kernel@vger.kernel.org
> Subject: Re: [RFC] Enabling other oom schemes

[snip]

> Imagine a process that consumes 51% of memory.  With strict 
> overcommit, 
> that process cannot fork() since there is not enough memory.

Let's put some quantification on this thought experiment. Imagine a 4
gigabyte "timesharing" server with hundreds of users. Each user has a few
processes consuming perhaps 5 - 50 megabytes of virtual address space. In
this context, a single userspace process consuming 51 percent of real memory
-- a tad over 2 gigabytes -- not only cannot fork *itself*, but also most
likely is interfering with the operations of the other users. Most likely
hundreds of voices would be raised in protest against the 2 gigabyte
process, and, if Linux didn't wipe it off the face of the Earth, the
managers of the server would. At the very least it would be "suggested" to
the 2 gigabyte process owner that a separate machine be procured to run it,
or another 2 gigabytes would be purchased to accommodate it in the same
server.

Now, imagine that 4 gigabyte server has, instead of a 2+ gigabyte userspace
process, 2+ gigabytes of RAM tied up in page cache. The effect on the
hundreds of users is the same, but there's a difference: because the
*kernel* owns the page cache, and not a "mere userspace process", the OOM
killer won't deal with it. And the server managers may not be able to deal
with it either, since we don't expect them to be authorized to re-code the
kernel or change the Linux memory management philosophy.



-- 
M. Edward (Ed) Borasky
mailto:znmeb@borasky-research.net
http://www.borasky-research.net/RunYourOwnBrain/
 
"Suppose that tonight, while you sleep, a miracle happens - you wake up
tomorrow with what you have longed for! How will you discover that a miracle
happened? How will your loved ones? What will be different? What will you
notice? What do you need to explode into tomorrow with grace, power, love,
passion and confidence?" -- L. Michael Hall, PhD


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

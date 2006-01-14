Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e5.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id k0EKjfsr024792
	for <linux-mm@kvack.org>; Sat, 14 Jan 2006 15:45:41 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VERS6.8) with ESMTP id k0EKjcDQ121606
	for <linux-mm@kvack.org>; Sat, 14 Jan 2006 15:45:41 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11/8.13.3) with ESMTP id k0EKjbib024479
	for <linux-mm@kvack.org>; Sat, 14 Jan 2006 15:45:37 -0500
Message-ID: <43C962F0.30400@us.ibm.com>
Date: Sat, 14 Jan 2006 14:45:36 -0600
From: Brian Twichell <tbrian@us.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH/RFC] Shared page tables
References: <A6D73CCDC544257F3D97F143@[10.1.1.4]> <43C7C4C7.8050409@cfl.rr.com>
In-Reply-To: <43C7C4C7.8050409@cfl.rr.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Phillip Susi <psusi@cfl.rr.com>
Cc: Dave McCracken <dmccr@us.ibm.com>, Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@osdl.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Phillip Susi wrote:

> Shouldn't those kind of applications already be using threads to share 
> page tables rather than forking hundreds of processes that all mmap() 
> the same file?
>
We're talking about sharing anonymous memory here, not files.

The feedback we've gotten on converting from a process-based to a 
thread-based model is that it's a major undertaking,
when development and test expense is considered.  It's understandable if 
one considers that they'd probably want to convert
across on several operating systems at once to minimize the number of 
source trees they have to maintain.

Also, the case for conversion isn't helped by the fact that at least two 
prominent commercial UNIX flavors either inherently
share page tables, or provide an explicit memory allocation mechanism 
that achieves page table sharing (e.g. Intimate Shared
Memory).

Cheers,
Brian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

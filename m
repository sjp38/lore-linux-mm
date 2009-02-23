Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 52EB06B00DB
	for <linux-mm@kvack.org>; Mon, 23 Feb 2009 14:27:06 -0500 (EST)
Message-ID: <49A2F885.8030407@goop.org>
Date: Mon, 23 Feb 2009 11:27:01 -0800
From: Jeremy Fitzhardinge <jeremy@goop.org>
MIME-Version: 1.0
Subject: Re: [PATCH RFC] vm_unmap_aliases: allow callers to inhibit TLB flush
References: <49416494.6040009@goop.org> <200902231514.01965.nickpiggin@yahoo.com.au> <49A25086.30606@goop.org> <200902232013.43054.nickpiggin@yahoo.com.au>
In-Reply-To: <200902232013.43054.nickpiggin@yahoo.com.au>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, the arch/x86 maintainers <x86@kernel.org>, Arjan van de Ven <arjan@linux.intel.com>
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:
> Here's a start for you. I think it gets rid of all the dead code and
> data without introducing any actual conditional compilation...
>   

OK, I can get started with this, but it will need to be a runtime 
switch; a Xen kernel running native is just a normal kernel, and I don't 
think we want to disable lazy flushes in that case.

    J

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

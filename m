Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 45DED6B003D
	for <linux-mm@kvack.org>; Wed, 18 Mar 2009 19:37:32 -0400 (EDT)
Message-ID: <49C185B4.90004@goop.org>
Date: Wed, 18 Mar 2009 16:37:24 -0700
From: Jeremy Fitzhardinge <jeremy@goop.org>
MIME-Version: 1.0
Subject: Re: Question about x86/mm/gup.c's use of disabled interrupts
References: <49C148AF.5050601@goop.org> <49C16411.2040705@redhat.com>	 <49C1665A.4080707@goop.org> <49C16A48.4090303@redhat.com>	 <49C17230.20109@goop.org> <49C17880.7080109@redhat.com>	 <49C17BD8.6050609@goop.org> <49C17E22.9040807@redhat.com> <70513aa50903181617r418ec23s744544dccfd812e8@mail.gmail.com>
In-Reply-To: <70513aa50903181617r418ec23s744544dccfd812e8@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Shentino <shentino@gmail.com>
Cc: Avi Kivity <avi@redhat.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Xen-devel <xen-devel@lists.xensource.com>, Jan Beulich <jbeulich@novell.com>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

Shentino wrote:
> But, does a CPU running a task in userspace effectively have a read 
> lock on the page tables?

No.  A process has its own user pagetable which the kernel maintains on 
its behalf.  The kernel will briefly take locks on it while doing 
modifications, mostly to deal with multithreaded usermode code running 
on multiple cpus.

    J

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

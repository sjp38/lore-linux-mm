Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f173.google.com (mail-qc0-f173.google.com [209.85.216.173])
	by kanga.kvack.org (Postfix) with ESMTP id 5A0686B007B
	for <linux-mm@kvack.org>; Mon, 22 Dec 2014 13:05:26 -0500 (EST)
Received: by mail-qc0-f173.google.com with SMTP id i17so3684731qcy.32
        for <linux-mm@kvack.org>; Mon, 22 Dec 2014 10:05:26 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id g6si4263593qga.61.2014.12.22.10.05.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 22 Dec 2014 10:05:25 -0800 (PST)
Message-ID: <54985D59.5010506@oracle.com>
Date: Mon, 22 Dec 2014 13:05:13 -0500
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: mm: NULL ptr deref in unlink_file_vma
References: <549832E2.8060609@oracle.com> <20141222180102.GA8072@node.dhcp.inet.fi>
In-Reply-To: <20141222180102.GA8072@node.dhcp.inet.fi>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>, "david S. Miller" <davem@davemloft.net>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Jones <davej@redhat.com>, dave@stgolabs.net

On 12/22/2014 01:01 PM, Kirill A. Shutemov wrote:
> On Mon, Dec 22, 2014 at 10:04:02AM -0500, Sasha Levin wrote:
>> > Hi all,
>> > 
>> > While fuzzing with trinity inside a KVM tools guest running the latest -next
>> > kernel, I've stumbled on the following spew:
>> > 
>> > [  432.376425] BUG: unable to handle kernel NULL pointer dereference at 0000000000000038
>> > [  432.378876] IP: down_write (./arch/x86/include/asm/rwsem.h:105 ./arch/x86/include/asm/rwsem.h:121 kernel/locking/rwsem.c:71)
> Looks like vma->vm_file->mapping is NULL. Somebody freed ->vm_file from
> under us?
> 
> I suspect Davidlohr's patchset on i_mmap_lock, but I cannot find any code
> path which could lead to the crash.

I've reported a different issue which that patchset: https://lkml.org/lkml/2014/12/9/741

I guess it could be related?


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

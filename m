Date: Sat, 22 Oct 2005 14:11:33 -0400 (EDT)
From: Rik van Riel <riel@redhat.com>
Subject: Re: a basic question
In-Reply-To: <f68e01850510220909wad86b06wadc620fb5f807b5d@mail.gmail.com>
Message-ID: <Pine.LNX.4.63.0510221409460.6999@cuia.boston.redhat.com>
References: <f68e01850510220909wad86b06wadc620fb5f807b5d@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nitin Gupta <nitingupta.mail@gmail.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 22 Oct 2005, Nitin Gupta wrote:

> - How does processor know that 3GB-4GB is mapped linearly on first 1GB
> of memory. Is there a pagetable for this segment mapping it linearly?

Yes, there are page tables for this.

> - Why isn't it like this  - userspace tasks have 4GB virtual address
> space and for kernel also a 4GB virtual address space that is linearly
> mapped to fist 4GB of memory.

With the 4:4 split patch, this is done.  However, there is a
cost to this approach - every time the system switches from
user mode to kernel mode it goes through a context switch.

An extra two context swiches on every system call, every 
interrupt. For most systems the gained space is simply not 
worth the time overhead.

-- 
All Rights Reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

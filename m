Date: Tue, 29 Aug 2000 00:09:35 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: pgd/pmd/pte and x86 kernel virtual addresses
Message-ID: <20000829000935.K1467@redhat.com>
References: <20000825165116Z131177-250+7@kanga.kvack.org> <Pine.LNX.3.96.1000825125457.23502B-100000@kanga.kvack.org> <20000825185716Z131186-247+10@kanga.kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20000825185716Z131186-247+10@kanga.kvack.org>; from ttabi@interactivesi.com on Fri, Aug 25, 2000 at 01:46:33PM -0500
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Timur Tabi <ttabi@interactivesi.com>
Cc: Linux MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

On Fri, Aug 25, 2000 at 01:46:33PM -0500, Timur Tabi wrote:

> physical pointer.  The first is the normal virtual pointer for kernel memory,
> and the second is the one returned by ioremap_nocache().  I was under the
> understanding that caching is enabled on physical pages only, so it shouldn't
> matter which virtual address I use.  Is that correct?

No.  The no-cache bit is set in the page table entry, so depends on
the virtual address.  There is a *different* form of memory access
control which can be used to make memory non-cachable, and that is the
"mtrr" (Memory Type Range Register), which exists in different forms
on all recent Intel and AMD cpus.  Mtrrs work on physical addresses,
but that is not what ioremap_nocache() uses.

--Stephen

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

From: Daniel Phillips <phillips@arcor.de>
Subject: Re: What to expect with the 2.6 VM
Date: Mon, 30 Jun 2003 19:43:04 +0200
References: <Pine.LNX.4.53.0307010238210.22576@skynet>
In-Reply-To: <Pine.LNX.4.53.0307010238210.22576@skynet>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200306301943.04326.phillips@arcor.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>, Linux Memory Management List <linux-mm@kvack.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tuesday 01 July 2003 03:39, Mel Gorman wrote:
> I'm writing a small paper on the 2.6 VM for a conference.

Nice stuff, and very timely.

>    In 2.4, Page Table Entries (PTEs) must be allocated from ZONE_ NORMAL as
>    the kernel needs to address them directly for page table traversal. In a
>    system with many tasks or with large mapped memory regions, this can
>    place significant pressure on ZONE_ NORMAL so 2.6 has the option of
>    allocating PTEs from high memory.

You probably ought to mention that this is only needed by 32 bit architectures 
with silly amounts of memory installed.  On that topic, you might mention 
that the VM subsystem generally gets simpler and in some cases faster (i.e., 
no more highmem mapping cost) in the move to 64 bits.

You also might want to mention pdflush.

Regards,

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

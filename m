Message-ID: <3A6F22D7.3000709@valinux.com>
Date: Wed, 24 Jan 2001 11:45:43 -0700
From: Jeff Hartmann <jhartmann@valinux.com>
MIME-Version: 1.0
Subject: Re: Page Attribute Table (PAT) support?
References: <20010124174824Z129401-18594+948@vger.kernel.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Timur Tabi <ttabi@interactivesi.com>
Cc: Linux Kernel Mailing list <linux-kernel@vger.kernel.org>, Linux MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Timur Tabi wrote:

> The Page Attribute Table (PAT) is an extension to the x86 page table format
> that lets you enable Write Combining on a per-page basis.  Details can be found
> in chapter 9.13 of the Intel Architecture Software Developer's Manual, Volume 3
> (System Programming).
> 
> I noticed that 2.4 doesn't support the Page Attribute Table, despite the fact
> that it has a X86_FEATURE_PAT macro in processor.h.  Are there any plans to add
> this support?  Ideally, I'd like it to be as a parameter for ioremap.

I'm actually writing support for the PAT as we speak.  I already have 
working code for PAT setup.  Just having a parameter for ioremap is not 
enough, unfortunately.  According to the Intel Architecture Software 
Developer's Manual we have to remove all mappings of the page that are 
cached.  Only then can they be mapped with per page write combining.  I 
should have working code by the 2.5.x timeframe.  I can also discuss the 
planned interface if anyone is interested.

-Jeff

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

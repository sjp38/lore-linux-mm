Message-ID: <3A6F3E05.4090409@valinux.com>
Date: Wed, 24 Jan 2001 13:41:41 -0700
From: Jeff Hartmann <jhartmann@valinux.com>
MIME-Version: 1.0
Subject: Re: Page Attribute Table (PAT) support?
References: <20010124174824Z129401-18594+948@vger.kernel.org> <20010124203012Z129444-18594+1042@vger.kernel.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Timur Tabi <ttabi@interactivesi.com>
Cc: Linux Kernel Mailing list <linux-kernel@vger.kernel.org>, Linux MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Timur Tabi wrote:

> ** Reply to message from Jeff Hartmann <jhartmann@valinux.com> on Wed, 24 Jan
> 2001 11:45:43 -0700
> 
> 
> 
>> I'm actually writing support for the PAT as we speak.  I already have 
>> working code for PAT setup.  Just having a parameter for ioremap is not 
>> enough, unfortunately.  According to the Intel Architecture Software 
>> Developer's Manual we have to remove all mappings of the page that are 
>> cached.
> 
> 
> For our specific purposes, that's not important.  We already flush the cache
> before we create uncached regions (via ioremap_nocache).  I understand that as a
> general Linux feature, you can't ignore cache incoherency, but I don't think
> it's a hard requirement.

Actually you can't ignore it or the processor will have a heart attack 
if the cached page mapping is used even speculatively.  I've done some 
experimenting, if the page is mapped cached in one place, and UCWC in 
another, things will not work.  Its extremely likely the processor will 
cease to function.  Its not like having cached and uncached mappings of 
a page (which does work on the Intel processors, we use that feature in 
the agpgart and the DRM in fact.)  When you mark a page UCWC, you better 
have removed all cached mappings or your asking for REAL trouble.

-Jeff

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

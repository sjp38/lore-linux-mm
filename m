Date: Fri, 4 Oct 2002 11:03:00 -0400
From: Benjamin LaHaise <bcrl@redhat.com>
Subject: Re: remap_page_range() beyond 4GB
Message-ID: <20021004110300.B1269@redhat.com>
References: <20021004134259.41743.qmail@web12802.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20021004134259.41743.qmail@web12802.mail.yahoo.com>; from reddy_cdi@yahoo.com on Fri, Oct 04, 2002 at 06:42:59AM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: sreekanth reddy <reddy_cdi@yahoo.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Oct 04, 2002 at 06:42:59AM -0700, sreekanth reddy wrote:
> How can I "remap_page_range()" for physical addresses
> beyond 4GB ? . remap_page_range()takes a 32 bit
> (unsigned long) value which cannot address > 4GB
> physical memory.

What are you using remap_page_range() on?  It should never be used on 
RAM.

		-ben
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

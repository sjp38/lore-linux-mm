Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 1362B6B01EE
	for <linux-mm@kvack.org>; Tue,  6 Apr 2010 01:43:45 -0400 (EDT)
Subject: Re: mprotect pgprot handling weirdness
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <1270530566.13812.28.camel@pasglop>
References: <1270530566.13812.28.camel@pasglop>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 06 Apr 2010 15:43:42 +1000
Message-ID: <1270532622.13812.30.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2010-04-06 at 15:09 +1000, Benjamin Herrenschmidt wrote:
> (*) Right now it's near impossible to add arch specific PROT_* bits to
> mmap/mprotect for fancy things like cachability attributes, or other
> nifty things like reverse-endian mappings that we have on some embedded
> platforms, I'm investigating ways to better separate vm_page_prot from
> vm_flags so some PROT_* bits can go straight to the former without
> having to be mirrored in some way in the later.

The other (easier) option is to make the vm flags always 64-bit and
reserve a range of bits here for the arch to use but I suppose there's
going to be unhappiness about that one :-)

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Subject: Re: [rfc] 2.6.19-rc1-git5: consolidation of file backed fault
	handlers
From: Arjan van de Ven <arjan@infradead.org>
In-Reply-To: <20061010150142.GE2431@wotan.suse.de>
References: <20061010121314.19693.75503.sendpatchset@linux.site>
	 <20061010143342.GA5580@infradead.org> <20061010150142.GE2431@wotan.suse.de>
Content-Type: text/plain
Date: Tue, 10 Oct 2006 18:09:06 +0200
Message-Id: <1160496546.3000.315.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Christoph Hellwig <hch@infradead.org>, Linux Memory Management <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>, Linux Kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

> \ What:	vm_ops.nopage
> -When:	October 2008, provided in-kernel callers have been converted
> +When:	October 2007, provided in-kernel callers have been converted
>  Why:	This interface is replaced by vm_ops.fault, but it has been around
>  	forever, is used by a lot of drivers, and doesn't cost much to
>  	maintain.

but a year is a really long time; 6 months would be a lot more
reasonable..
(it's not as if most external modules will switch until it's really
gone.. more notice isn't really going to help that at all; at least make
the kernel printk once on the first use of this so that they notice!)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

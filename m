Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 11B6D6B002B
	for <linux-mm@kvack.org>; Tue, 16 Oct 2012 10:41:49 -0400 (EDT)
Message-ID: <1350398501.2532.12.camel@dabdike>
Subject: Re: dma_alloc_coherent fails in framebuffer
From: James Bottomley <James.Bottomley@HansenPartnership.com>
Date: Tue, 16 Oct 2012 07:41:41 -0700
In-Reply-To: <CAA_GA1cPE+m8N1LQA2iOym4jbFwcHG+K2p-3iBovPWuf1N1q+g@mail.gmail.com>
References: <1350192523.10946.4.camel@gitbox>
	 <1350246895.11504.6.camel@gitbox> <20121015094547.GC29125@suse.de>
	 <1350325704.31162.16.camel@gitbox>
	 <CAA_GA1cPE+m8N1LQA2iOym4jbFwcHG+K2p-3iBovPWuf1N1q+g@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: Tony Prisk <linux@prisktech.co.nz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Arm Kernel Mailing List <linux-arm-kernel@lists.infradead.org>, Arnd Bergmann <arnd@arndb.de>

On Tue, 2012-10-16 at 10:17 +0800, Bob Liu wrote:
> I think you need to declare that memory using
> dma_declare_coherent_memory() before
> alloc_from_coherent.

This isn't true.  Almost every platform has a mechanism for
manufacturing coherent memory (in the worst case, they just turn off the
CPU cache on a page and hand it out).  The purpose of
dma_declare_coherent_memory() is to allow a per device declaration of
preferred regions ... usually because they reside either on the fast
path to the device or sometimes on the device itself.  There are only a
handful of devices which need it, so in the ordinary course of events,
dma_alloc_coherent() is used without any memory declaration.

James


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

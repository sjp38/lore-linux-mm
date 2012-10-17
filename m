Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id D388B6B002B
	for <linux-mm@kvack.org>; Tue, 16 Oct 2012 22:26:08 -0400 (EDT)
Received: by mail-wg0-f45.google.com with SMTP id dq12so5103952wgb.26
        for <linux-mm@kvack.org>; Tue, 16 Oct 2012 19:26:07 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1350398501.2532.12.camel@dabdike>
References: <1350192523.10946.4.camel@gitbox>
	<1350246895.11504.6.camel@gitbox>
	<20121015094547.GC29125@suse.de>
	<1350325704.31162.16.camel@gitbox>
	<CAA_GA1cPE+m8N1LQA2iOym4jbFwcHG+K2p-3iBovPWuf1N1q+g@mail.gmail.com>
	<1350398501.2532.12.camel@dabdike>
Date: Wed, 17 Oct 2012 10:26:07 +0800
Message-ID: <CAA_GA1d_twVqv9jOGx74wvYiuJwQQDAN-NJB_x61df=--yP6Og@mail.gmail.com>
Subject: Re: dma_alloc_coherent fails in framebuffer
From: Bob Liu <lliubbo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@hansenpartnership.com>
Cc: Tony Prisk <linux@prisktech.co.nz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Arm Kernel Mailing List <linux-arm-kernel@lists.infradead.org>, Arnd Bergmann <arnd@arndb.de>

On Tue, Oct 16, 2012 at 10:41 PM, James Bottomley
<James.Bottomley@hansenpartnership.com> wrote:
> On Tue, 2012-10-16 at 10:17 +0800, Bob Liu wrote:
>> I think you need to declare that memory using
>> dma_declare_coherent_memory() before
>> alloc_from_coherent.
>
> This isn't true.  Almost every platform has a mechanism for
> manufacturing coherent memory (in the worst case, they just turn off the
> CPU cache on a page and hand it out).  The purpose of
> dma_declare_coherent_memory() is to allow a per device declaration of
> preferred regions ... usually because they reside either on the fast
> path to the device or sometimes on the device itself.  There are only a
> handful of devices which need it, so in the ordinary course of events,
> dma_alloc_coherent() is used without any memory declaration.
>

Sorry for my ambiguity.
It obviously true we can use dma_alloc_coherent() without any memory
declaration.

I thought Tony's original idea was want to make
dma_alloc_from_coherent() return success.
But the dev->dma_mem check can't pass, so i suggested him using
dma_declare_coherent_memory()
to declare per-device area first.

Thanks,
--Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

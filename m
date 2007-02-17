Received: by nf-out-0910.google.com with SMTP id b2so1681319nfe
        for <linux-mm@kvack.org>; Sat, 17 Feb 2007 01:47:55 -0800 (PST)
Message-ID: <45a44e480702170147x73d1e5c8v6439ac412b952a7@mail.gmail.com>
Date: Sat, 17 Feb 2007 10:47:54 +0100
From: "Jaya Kumar" <jayakumar.lkml@gmail.com>
Subject: Re: [PATCH/RFC 2.6.20-rc4 1/1] fbdev,mm: hecuba/E-Ink fbdev driver
In-Reply-To: <45A6DAA2.8070605@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070111142427.GA1668@localhost>
	 <20070111133759.d17730a4.akpm@osdl.org>
	 <45a44e480701111622i32fffddcn3b4270d539620743@mail.gmail.com>
	 <45A6DAA2.8070605@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andrew Morton <akpm@osdl.org>, linux-fbdev-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 1/12/07, Nick Piggin <nickpiggin@yahoo.com.au> wrote:
> Jaya Kumar wrote:
> > - write so get page_mkwrite where we add this page to a list
> > - also schedules a workqueue task to be run after a delay
> > - app continues writing to that page with no additional cost
> > - the workqueue task comes in and unmaps the pages on the list, then
> >  completes the work associated with updating the framebuffer
>
> Have you thought about implementing a traditional write-back cache using
> the dirty bits, rather than unmapping the page?
>

Ah, sorry, I erred in my description. I'm not unmapping pages, I'm
calling page_mkclean which uses the dirty bits.

Thanks,
jaya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

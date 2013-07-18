Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id B46FC6B0033
	for <linux-mm@kvack.org>; Thu, 18 Jul 2013 09:42:48 -0400 (EDT)
Date: Thu, 18 Jul 2013 13:42:47 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] mm/slub.c: use 'unsigned long' instead of 'int' for
 variable 'slub_debug'
In-Reply-To: <51E73340.5020703@asianux.com>
Message-ID: <0000013ff204c901-636c5864-ec23-4c31-a308-d7fd58016364-000000@email.amazonses.com>
References: <51DF5F43.3080408@asianux.com> <0000013fd3283b9c-b5fe217c-fff3-47fd-be0b-31b00faba1f3-000000@email.amazonses.com> <51E33FFE.3010200@asianux.com> <0000013fe2b1bd10-efcc76b5-f75b-4a45-a278-a318e87b2571-000000@email.amazonses.com> <51E49982.30402@asianux.com>
 <0000013fed18f0f2-cb1afad0-560e-4da5-b865-29e854ce5813-000000@email.amazonses.com> <51E73340.5020703@asianux.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Gang <gang.chen@asianux.com>
Cc: Pekka Enberg <penberg@kernel.org>, mpm@selenic.com, linux-mm@kvack.org

On Thu, 18 Jul 2013, Chen Gang wrote:

> On 07/17/2013 10:46 PM, Christoph Lameter wrote:
> > On Tue, 16 Jul 2013, Chen Gang wrote:
> >
> >> If we really use 32-bit as unsigned number, better to use 'U' instead of
> >> 'UL' (e.g. 0x80000000U instead of 0x80000000UL).
> >>
> >> Since it is unsigned 32-bit number, it is better to use 'unsigned int'
> >> instead of 'int', which can avoid related warnings if "EXTRA_CFLAGS=-W".
> >
> > Ok could you go through the kernel source and change that?
> >
>
> Yeah, thanks, I should do it.
>
> Hmm... for each case of this issue, it need communicate with (review by)
> various related maintainers.
>
> So, I think one patch for one variable (and related macro contents) is
> enough.
>
> Is it OK ?

The fundamental issue is that typically ints are used for flags and I
would like to keep it that way. Changing the constants in slab.h and the
allocator code to be unsigned int instead of unsigned long wont be that
much of a deal.

Will the code then be clean enough for you?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

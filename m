Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 44B3E6B0044
	for <linux-mm@kvack.org>; Sat, 13 Oct 2012 05:54:52 -0400 (EDT)
Received: by mail-da0-f41.google.com with SMTP id i14so2002819dad.14
        for <linux-mm@kvack.org>; Sat, 13 Oct 2012 02:54:51 -0700 (PDT)
Date: Sat, 13 Oct 2012 02:54:49 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [Q] Default SLAB allocator
In-Reply-To: <CALF0-+WLZWtwYY4taYW9D7j-abCJeY90JzcTQ2hGK64ftWsdxw@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1210130252030.7462@chino.kir.corp.google.com>
References: <CALF0-+XGn5=QSE0bpa4RTag9CAJ63MKz1kvaYbpw34qUhViaZA@mail.gmail.com> <m27gqwtyu9.fsf@firstfloor.org> <alpine.DEB.2.00.1210111558290.6409@chino.kir.corp.google.com> <m2391ktxjj.fsf@firstfloor.org>
 <CALF0-+WLZWtwYY4taYW9D7j-abCJeY90JzcTQ2hGK64ftWsdxw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ezequiel Garcia <elezegarcia@gmail.com>
Cc: Andi Kleen <andi@firstfloor.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Tim Bird <tim.bird@am.sony.com>, celinux-dev@lists.celinuxforum.org

On Fri, 12 Oct 2012, Ezequiel Garcia wrote:

> >> SLUB is a non-starter for us and incurs a >10% performance degradation in
> >> netperf TCP_RR.
> >
> 
> Where are you seeing that?
> 

In my benchmarking results.

> Notice that many defconfigs are for embedded devices,
> and many of them say "use SLAB"; I wonder if that's right.
> 

If a device doesn't require the smallest memory footprint possible (SLOB) 
then SLAB is the right choice when there's a limited amount of memory; 
SLUB requires higher order pages for the best performance (on my desktop 
system running with CONFIG_SLUB, over 50% of the slab caches default to be 
high order).

> Is there any intention to replace SLAB by SLUB?

There may be an intent, but it'll be nacked as long as there's a 
performance degradation.

> In that case it could make sense to change defconfigs, although
> it wouldn't be based on any actual tests.
> 

Um, you can't just go changing defconfigs without doing some due diligence 
in ensuring it won't be deterimental for those users.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

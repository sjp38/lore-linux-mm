Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id E4EBD6B002B
	for <linux-mm@kvack.org>; Thu, 11 Oct 2012 18:59:21 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id rq2so2557580pbb.14
        for <linux-mm@kvack.org>; Thu, 11 Oct 2012 15:59:21 -0700 (PDT)
Date: Thu, 11 Oct 2012 15:59:19 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [Q] Default SLAB allocator
In-Reply-To: <m27gqwtyu9.fsf@firstfloor.org>
Message-ID: <alpine.DEB.2.00.1210111558290.6409@chino.kir.corp.google.com>
References: <CALF0-+XGn5=QSE0bpa4RTag9CAJ63MKz1kvaYbpw34qUhViaZA@mail.gmail.com> <m27gqwtyu9.fsf@firstfloor.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Ezequiel Garcia <elezegarcia@gmail.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Tim Bird <tim.bird@am.sony.com>, celinux-dev@lists.celinuxforum.org

On Thu, 11 Oct 2012, Andi Kleen wrote:

> > While I've always thought SLUB was the default and recommended allocator,
> > I'm surprise to find that it's not always the case:
> 
> iirc the main performance reasons for slab over slub have mostly
> disappeared, so in theory slab could be finally deprecated now.
> 

SLUB is a non-starter for us and incurs a >10% performance degradation in 
netperf TCP_RR.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

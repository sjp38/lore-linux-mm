Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 918156B005A
	for <linux-mm@kvack.org>; Tue, 16 Oct 2012 08:56:05 -0400 (EDT)
Received: by mail-bk0-f41.google.com with SMTP id jm1so2920358bkc.14
        for <linux-mm@kvack.org>; Tue, 16 Oct 2012 05:56:03 -0700 (PDT)
Subject: Re: [Q] Default SLAB allocator
From: Eric Dumazet <eric.dumazet@gmail.com>
In-Reply-To: <CALF0-+WgfnNOOZwj+WLB397cgGX7YhNuoPXAK5E0DZ5v_BxxEA@mail.gmail.com>
References: 
	 <CALF0-+XGn5=QSE0bpa4RTag9CAJ63MKz1kvaYbpw34qUhViaZA@mail.gmail.com>
	 <m27gqwtyu9.fsf@firstfloor.org>
	 <alpine.DEB.2.00.1210111558290.6409@chino.kir.corp.google.com>
	 <m2391ktxjj.fsf@firstfloor.org>
	 <CALF0-+WLZWtwYY4taYW9D7j-abCJeY90JzcTQ2hGK64ftWsdxw@mail.gmail.com>
	 <alpine.DEB.2.00.1210130252030.7462@chino.kir.corp.google.com>
	 <CALF0-+Xp_P_NjZpifzDSWxz=aBzy_fwaTB3poGLEJA8yBPQb_Q@mail.gmail.com>
	 <alpine.DEB.2.00.1210151745400.31712@chino.kir.corp.google.com>
	 <CALF0-+WgfnNOOZwj+WLB397cgGX7YhNuoPXAK5E0DZ5v_BxxEA@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 16 Oct 2012 14:56:00 +0200
Message-ID: <1350392160.3954.986.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ezequiel Garcia <elezegarcia@gmail.com>
Cc: David Rientjes <rientjes@google.com>, Andi Kleen <andi@firstfloor.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Tim Bird <tim.bird@am.sony.com>, celinux-dev@lists.celinuxforum.org

On Tue, 2012-10-16 at 09:35 -0300, Ezequiel Garcia wrote:

> Now, returning to the fragmentation. The problem with SLAB is that
> its smaller cache available for kmalloced objects is 32 bytes;
> while SLUB allows 8, 16, 24 ...
> 
> Perhaps adding smaller caches to SLAB might make sense?
> Is there any strong reason for NOT doing this?

I would remove small kmalloc-XX caches, as sharing a cache line
is sometime dangerous for performance, because of false sharing.

They make sense only for very small hosts.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id C3AE56B0073
	for <linux-mm@kvack.org>; Mon, 15 Oct 2012 20:46:05 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id rq2so6135931pbb.14
        for <linux-mm@kvack.org>; Mon, 15 Oct 2012 17:46:05 -0700 (PDT)
Date: Mon, 15 Oct 2012 17:46:03 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [Q] Default SLAB allocator
In-Reply-To: <CALF0-+Xp_P_NjZpifzDSWxz=aBzy_fwaTB3poGLEJA8yBPQb_Q@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1210151745400.31712@chino.kir.corp.google.com>
References: <CALF0-+XGn5=QSE0bpa4RTag9CAJ63MKz1kvaYbpw34qUhViaZA@mail.gmail.com> <m27gqwtyu9.fsf@firstfloor.org> <alpine.DEB.2.00.1210111558290.6409@chino.kir.corp.google.com> <m2391ktxjj.fsf@firstfloor.org> <CALF0-+WLZWtwYY4taYW9D7j-abCJeY90JzcTQ2hGK64ftWsdxw@mail.gmail.com>
 <alpine.DEB.2.00.1210130252030.7462@chino.kir.corp.google.com> <CALF0-+Xp_P_NjZpifzDSWxz=aBzy_fwaTB3poGLEJA8yBPQb_Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ezequiel Garcia <elezegarcia@gmail.com>
Cc: Andi Kleen <andi@firstfloor.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Tim Bird <tim.bird@am.sony.com>, celinux-dev@lists.celinuxforum.org

On Sat, 13 Oct 2012, Ezequiel Garcia wrote:

> But SLAB suffers from a lot more internal fragmentation than SLUB,
> which I guess is a known fact. So memory-constrained devices
> would waste more memory by using SLAB.

Even with slub's per-cpu partial lists?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

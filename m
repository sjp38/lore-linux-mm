Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 3323B6B005A
	for <linux-mm@kvack.org>; Tue, 16 Oct 2012 14:54:45 -0400 (EDT)
Date: Tue, 16 Oct 2012 18:54:44 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [Q] Default SLAB allocator
In-Reply-To: <CALF0-+XLXAh3=OScQ=V0F80ZcnTGjHox68SApOwPUYVvmjdqPw@mail.gmail.com>
Message-ID: <0000013a6aed8d12-71a82caf-366a-425c-a963-79077f62d673-000000@email.amazonses.com>
References: <CALF0-+XGn5=QSE0bpa4RTag9CAJ63MKz1kvaYbpw34qUhViaZA@mail.gmail.com> <m27gqwtyu9.fsf@firstfloor.org> <alpine.DEB.2.00.1210111558290.6409@chino.kir.corp.google.com> <m2391ktxjj.fsf@firstfloor.org> <CALF0-+WLZWtwYY4taYW9D7j-abCJeY90JzcTQ2hGK64ftWsdxw@mail.gmail.com>
 <alpine.DEB.2.00.1210130252030.7462@chino.kir.corp.google.com> <CALF0-+Xp_P_NjZpifzDSWxz=aBzy_fwaTB3poGLEJA8yBPQb_Q@mail.gmail.com> <alpine.DEB.2.00.1210151745400.31712@chino.kir.corp.google.com> <CALF0-+WgfnNOOZwj+WLB397cgGX7YhNuoPXAK5E0DZ5v_BxxEA@mail.gmail.com>
 <1350392160.3954.986.camel@edumazet-glaptop> <507DA245.9050709@am.sony.com> <CALF0-+XLXAh3=OScQ=V0F80ZcnTGjHox68SApOwPUYVvmjdqPw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ezequiel Garcia <elezegarcia@gmail.com>
Cc: Tim Bird <tim.bird@am.sony.com>, Eric Dumazet <eric.dumazet@gmail.com>, David Rientjes <rientjes@google.com>, Andi Kleen <andi@firstfloor.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "celinux-dev@lists.celinuxforum.org" <celinux-dev@lists.celinuxforum.org>

On Tue, 16 Oct 2012, Ezequiel Garcia wrote:

> It might be worth reminding that very small systems can use SLOB
> allocator, which does not suffer from this kind of fragmentation.

Well, I have never seen non experimental systems that use SLOB. Others
have claimed they exist.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 084346B004F
	for <linux-mm@kvack.org>; Wed,  7 Oct 2009 04:59:36 -0400 (EDT)
Message-Id: <4ACC749602000078000186ED@vpn.id2.novell.com>
Date: Wed, 07 Oct 2009 09:59:34 +0100
From: "Jan Beulich" <JBeulich@novell.com>
Subject: Re: [PATCH] adjust gfp mask passed on nested vmalloc()
	 invocation
References: <4AC9E38E0200007800017F57@vpn.id2.novell.com>
 <Pine.LNX.4.64.0910062241500.21409@sister.anvils>
In-Reply-To: <Pine.LNX.4.64.0910062241500.21409@sister.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

>>> Hugh Dickins <hugh.dickins@tiscali.co.uk> 06.10.09 23:58 >>>
>On Mon, 5 Oct 2009, Jan Beulich wrote:
>
>> - fix a latent bug resulting from blindly or-ing in __GFP_ZERO, since
>>   the combination of this and __GFP_HIGHMEM (possibly passed into the
>>   function) is forbidden in interrupt context
>> - avoid wasting more precious resources (DMA or DMA32 pools), when
>>   being called through vmalloc_32{,_user}()
>> - explicitly allow using high memory here even if the outer allocation
>>   request doesn't allow it, unless is collides with __GFP_ZERO
>>=20
>> Signed-off-by: Jan Beulich <jbeulich@novell.com>
>
>I thought vmalloc.c was a BUG_ON(in_interrupt()) zone?
>The locking is all spin_lock stuff, not spin_lock_irq stuff.
>That's probably why your "bug" has remained "latent".

Actually, my previous reply to this was bogus, and I agree with your
statement. Hence, from a second version of the patch (depending on
your response on my question regarding the other part of your reply),
I should drop that part of the description.

Jan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

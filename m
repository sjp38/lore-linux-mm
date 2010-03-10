Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 10A3A6B00B4
	for <linux-mm@kvack.org>; Wed, 10 Mar 2010 09:33:35 -0500 (EST)
Date: Wed, 10 Mar 2010 08:33:06 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: 2.6.34-rc1: kernel BUG at mm/slab.c:2989!
In-Reply-To: <4B977282.40505@cs.helsinki.fi>
Message-ID: <alpine.DEB.2.00.1003100832200.17615@router.home>
References: <2375c9f91003100029q7d64bbf7xce15eee97f7e2190@mail.gmail.com> <4B977282.40505@cs.helsinki.fi>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: =?ISO-8859-15?Q?Am=E9rico_Wang?= <xiyou.wangcong@gmail.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, viro@zeniv.linux.org.uk, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, roland@redhat.com, peterz@infradead.org
List-ID: <linux-mm.kvack.org>

On Wed, 10 Mar 2010, Pekka Enberg wrote:

> > Please let me know if you need more info.
>
> Looks like regular SLAB corruption bug to me. Can you trigget it with SLUB?

Run SLUB with CONFIG_SLUB_DEBUG_ON or specify slub_debug on the kernel
command line to have all allocations checked.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

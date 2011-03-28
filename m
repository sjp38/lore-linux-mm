Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 2455A8D003B
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 02:25:15 -0400 (EDT)
Received: by vxk20 with SMTP id 20so2304591vxk.14
        for <linux-mm@kvack.org>; Sun, 27 Mar 2011 23:25:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110328061929.GA24328@elte.hu>
References: <20110326112725.GA28612@elte.hu>
	<20110326114736.GA8251@elte.hu>
	<1301161507.2979.105.camel@edumazet-laptop>
	<alpine.DEB.2.00.1103261406420.24195@router.home>
	<alpine.DEB.2.00.1103261428200.25375@router.home>
	<alpine.DEB.2.00.1103261440160.25375@router.home>
	<AANLkTinTzKQkRcE2JvP_BpR0YMj82gppAmNo7RqgftCG@mail.gmail.com>
	<alpine.DEB.2.00.1103262028170.1004@router.home>
	<alpine.DEB.2.00.1103262054410.1373@router.home>
	<4D9026C8.6060905@cs.helsinki.fi>
	<20110328061929.GA24328@elte.hu>
Date: Mon, 28 Mar 2011 09:25:13 +0300
Message-ID: <AANLkTinpCa6GBjP3+fdantvOdbktqW8m_D0fGkAnCXYk@mail.gmail.com>
Subject: Re: [PATCH] slub: Disable the lockless allocator
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Christoph Lameter <cl@linux.com>, Linus Torvalds <torvalds@linux-foundation.org>, Eric Dumazet <eric.dumazet@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, akpm@linux-foundation.org, tj@kernel.org, npiggin@kernel.dk, rientjes@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Mar 28, 2011 at 9:19 AM, Ingo Molnar <mingo@elte.hu> wrote:
>> Tejun, does this look good to you as well? I think it should go
>> through the percpu tree. It's needed to fix a boot crash with
>> lockless SLUB fastpaths enabled.
>
> AFAICS Linus applied it already:
>
> d7c3f8cee81f: percpu: Omit segment prefix in the UP case for cmpxchg_double

Oh, I missed that. Did you test the patch, Ingo? It's missing
attributions and reference to the LKML discussion unfortunately...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

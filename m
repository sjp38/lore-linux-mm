Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 3E23F8D003B
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 03:26:57 -0400 (EDT)
Received: by bwz17 with SMTP id 17so3155438bwz.14
        for <linux-mm@kvack.org>; Mon, 28 Mar 2011 00:26:55 -0700 (PDT)
Subject: Re: [PATCH] slub: Disable the lockless allocator
From: Eric Dumazet <eric.dumazet@gmail.com>
In-Reply-To: <20110328063656.GA29462@elte.hu>
References: <1301161507.2979.105.camel@edumazet-laptop>
	 <alpine.DEB.2.00.1103261406420.24195@router.home>
	 <alpine.DEB.2.00.1103261428200.25375@router.home>
	 <alpine.DEB.2.00.1103261440160.25375@router.home>
	 <AANLkTinTzKQkRcE2JvP_BpR0YMj82gppAmNo7RqgftCG@mail.gmail.com>
	 <alpine.DEB.2.00.1103262028170.1004@router.home>
	 <alpine.DEB.2.00.1103262054410.1373@router.home>
	 <4D9026C8.6060905@cs.helsinki.fi> <20110328061929.GA24328@elte.hu>
	 <AANLkTinpCa6GBjP3+fdantvOdbktqW8m_D0fGkAnCXYk@mail.gmail.com>
	 <20110328063656.GA29462@elte.hu>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 28 Mar 2011 09:26:50 +0200
Message-ID: <1301297210.32248.6.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Pekka Enberg <penberg@kernel.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Christoph Lameter <cl@linux.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, akpm@linux-foundation.org, tj@kernel.org, npiggin@kernel.dk, rientjes@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Le lundi 28 mars 2011 A  08:36 +0200, Ingo Molnar a A(C)crit :

> I think we might still be missing the hunk below - or is it now not needed 
> anymore?


Its not needed anymore, once cmpxchg16b implementation works correctly
on !SMP build. (It does now with current linux-2.6 tree)



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 5C6748D003B
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 03:35:51 -0400 (EDT)
Received: by fxm18 with SMTP id 18so3156754fxm.14
        for <linux-mm@kvack.org>; Mon, 28 Mar 2011 00:35:46 -0700 (PDT)
Date: Mon, 28 Mar 2011 09:35:42 +0200
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] slub: Disable the lockless allocator
Message-ID: <20110328073542.GA16530@htj.dyndns.org>
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
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4D9026C8.6060905@cs.helsinki.fi>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Christoph Lameter <cl@linux.com>, Linus Torvalds <torvalds@linux-foundation.org>, Eric Dumazet <eric.dumazet@gmail.com>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, akpm@linux-foundation.org, npiggin@kernel.dk, rientjes@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hello,

Heh, a lot of activities over the weekend.

On Mon, Mar 28, 2011 at 09:12:24AM +0300, Pekka Enberg wrote:
> >@@ -37,13 +43,13 @@
> >  	pushf
> >  	cli
> >
> >-	cmpq %gs:(%rsi), %rax
> >+	cmpq SEG_PREFIX(%rsi), %rax
> >  	jne not_same
> >-	cmpq %gs:8(%rsi), %rdx
> >+	cmpq SEG_PREFIX 8(%rsi), %rdx
> >  	jne not_same
> >
> >-	movq %rbx, %gs:(%rsi)
> >-	movq %rcx, %gs:8(%rsi)
> >+	movq %rbx, SEG_PREFIX(%rsi)
> >+	movq %rcx, SEG_PREFIX 8(%rsi)
> >
> >  	popf
> >  	mov $1, %al
> 
> Tejun, does this look good to you as well? I think it should go
> through the percpu tree. It's needed to fix a boot crash with
> lockless SLUB fastpaths enabled.

Linus already applied it so it's all done now.  The patch looks okay
to me although I would like to have the SEG_PREFIX defined in
asm/percpu.h instead.  Well, we can do that later.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

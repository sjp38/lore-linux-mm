Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id D9E638D0040
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 12:06:41 -0400 (EDT)
Received: by fxm18 with SMTP id 18so3649721fxm.14
        for <linux-mm@kvack.org>; Mon, 28 Mar 2011 09:06:37 -0700 (PDT)
Date: Mon, 28 Mar 2011 18:06:32 +0200
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] percpu: avoid extra NOP in percpu_cmpxchg16b_double
Message-ID: <20110328160632.GD6736@htj.dyndns.org>
References: <1301161507.2979.105.camel@edumazet-laptop>
 <alpine.DEB.2.00.1103261406420.24195@router.home>
 <alpine.DEB.2.00.1103261428200.25375@router.home>
 <alpine.DEB.2.00.1103261440160.25375@router.home>
 <AANLkTinTzKQkRcE2JvP_BpR0YMj82gppAmNo7RqgftCG@mail.gmail.com>
 <alpine.DEB.2.00.1103262028170.1004@router.home>
 <alpine.DEB.2.00.1103262054410.1373@router.home>
 <1301212347.32248.1.camel@edumazet-laptop>
 <1301308335.3182.12.camel@edumazet-laptop>
 <alpine.DEB.2.00.1103280845480.7590@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1103280845480.7590@router.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Pekka Enberg <penberg@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, akpm@linux-foundation.org, npiggin@kernel.dk, rientjes@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Mar 28, 2011 at 08:46:05AM -0500, Christoph Lameter wrote:
> On Mon, 28 Mar 2011, Eric Dumazet wrote:
> 
> > Therefore, NOPX should be :
> >
> > P6_NOP3 on SMP
> > P6_NOP2 on !SMP
> 
> Acked-by: Christoph Lameter <cl@linux.com>

Applied to percpu#fixes-2.6.39.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

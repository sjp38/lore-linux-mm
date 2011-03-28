Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 537898D0047
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 09:46:12 -0400 (EDT)
Date: Mon, 28 Mar 2011 08:46:05 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] percpu: avoid extra NOP in percpu_cmpxchg16b_double
In-Reply-To: <1301308335.3182.12.camel@edumazet-laptop>
Message-ID: <alpine.DEB.2.00.1103280845480.7590@router.home>
References: <alpine.DEB.2.00.1103221635400.4521@tiger>  <20110324142146.GA11682@elte.hu>  <alpine.DEB.2.00.1103240940570.32226@router.home>  <AANLkTikb8rtSX5hQG6MQF4quymFUuh5Tw97TcpB0YfwS@mail.gmail.com>  <20110324172653.GA28507@elte.hu> <20110324185258.GA28370@elte.hu>
  <alpine.LFD.2.00.1103242005530.31464@localhost6.localdomain6>  <20110324192247.GA5477@elte.hu>  <AANLkTinBwM9egao496WnaNLAPUxhMyJmkusmxt+ARtnV@mail.gmail.com>  <20110326112725.GA28612@elte.hu> <20110326114736.GA8251@elte.hu>  <1301161507.2979.105.camel@edumazet-laptop>
  <alpine.DEB.2.00.1103261406420.24195@router.home>  <alpine.DEB.2.00.1103261428200.25375@router.home>  <alpine.DEB.2.00.1103261440160.25375@router.home>  <AANLkTinTzKQkRcE2JvP_BpR0YMj82gppAmNo7RqgftCG@mail.gmail.com>  <alpine.DEB.2.00.1103262028170.1004@router.home>
  <alpine.DEB.2.00.1103262054410.1373@router.home>  <1301212347.32248.1.camel@edumazet-laptop> <1301308335.3182.12.camel@edumazet-laptop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Pekka Enberg <penberg@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, akpm@linux-foundation.org, tj@kernel.org, npiggin@kernel.dk, rientjes@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 28 Mar 2011, Eric Dumazet wrote:

> Therefore, NOPX should be :
>
> P6_NOP3 on SMP
> P6_NOP2 on !SMP

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

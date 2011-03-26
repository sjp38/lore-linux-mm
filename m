Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 46AAC8D0040
	for <linux-mm@kvack.org>; Sat, 26 Mar 2011 15:31:00 -0400 (EDT)
Received: from mail-iy0-f169.google.com (mail-iy0-f169.google.com [209.85.210.169])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id p2QJUuSV007834
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=FAIL)
	for <linux-mm@kvack.org>; Sat, 26 Mar 2011 12:30:56 -0700
Received: by iyf13 with SMTP id 13so3127007iyf.14
        for <linux-mm@kvack.org>; Sat, 26 Mar 2011 12:30:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1103261406420.24195@router.home>
References: <alpine.DEB.2.00.1103221635400.4521@tiger> <20110324142146.GA11682@elte.hu>
 <alpine.DEB.2.00.1103240940570.32226@router.home> <AANLkTikb8rtSX5hQG6MQF4quymFUuh5Tw97TcpB0YfwS@mail.gmail.com>
 <20110324172653.GA28507@elte.hu> <20110324185258.GA28370@elte.hu>
 <alpine.LFD.2.00.1103242005530.31464@localhost6.localdomain6>
 <20110324192247.GA5477@elte.hu> <AANLkTinBwM9egao496WnaNLAPUxhMyJmkusmxt+ARtnV@mail.gmail.com>
 <20110326112725.GA28612@elte.hu> <20110326114736.GA8251@elte.hu>
 <1301161507.2979.105.camel@edumazet-laptop> <alpine.DEB.2.00.1103261406420.24195@router.home>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sat, 26 Mar 2011 12:30:36 -0700
Message-ID: <AANLkTin8jHz0a5oS4LWQCrYW2VDb9A0V2aL7O5dYaPBt@mail.gmail.com>
Subject: Re: [PATCH] slub: Disable the lockless allocator
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Ingo Molnar <mingo@elte.hu>, Pekka Enberg <penberg@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, akpm@linux-foundation.org, tj@kernel.org, npiggin@kernel.dk, rientjes@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sat, Mar 26, 2011 at 12:18 PM, Christoph Lameter <cl@linux.com> wrote:
>
> Right. RSI should be in the range of the values you printed.
> However, the determination RSI is independent of the emulation of the
> instruction. If RSI is set wrong then we should see these failures on
> machines that do not do the instruction emulation. A kvm run with Ingo's
> config should show the same issues. Will do that now.

I bet it's timing-dependent and/or dependent on some code layout
issue. Why else would the totally pointless previous patch have made
any difference for Ingo (the "SLUB: Write to per cpu data when
allocating it" thing seems to be pure voodoo programming)?

That said, this early in the boot I don't think we should have any
parallelism going on, so I don't see what could make those kinds of
random effects.

                             Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

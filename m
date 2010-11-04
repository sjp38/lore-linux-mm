Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 7DDA48D0001
	for <linux-mm@kvack.org>; Wed,  3 Nov 2010 23:13:35 -0400 (EDT)
Received: by qyk5 with SMTP id 5so760136qyk.14
        for <linux-mm@kvack.org>; Wed, 03 Nov 2010 20:13:34 -0700 (PDT)
From: Ben Gamari <bgamari.foss@gmail.com>
Subject: Re: [PATCH] Add Kconfig option for default swappiness
In-Reply-To: <alpine.DEB.2.00.1011021235130.21387@chino.kir.corp.google.com>
References: <1288668052-32036-1-git-send-email-bgamari.foss@gmail.com> <alpine.DEB.2.00.1011012030100.12298@chino.kir.corp.google.com> <87oca7evbo.fsf@gmail.com> <alpine.DEB.2.00.1011021235130.21387@chino.kir.corp.google.com>
Date: Wed, 03 Nov 2010 23:13:31 -0400
Message-ID: <878w19bx2c.fsf@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jesper Juhl <jj@chaosbits.net>, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

On Tue, 2 Nov 2010 12:39:52 -0700 (PDT), David Rientjes <rientjes@google.com> wrote:
> On Tue, 2 Nov 2010, Ben Gamari wrote:
> > Packaging concerns, as I mentioned before,
> 
> That you snipped from the changelog?
> 
Guilty as charged. Sorry about that, time has been in short supply
recently.

> You could say the same thing for any sysctl, it's not indicative of why 
> this particular change is needed in the kernel.
> 
This is certainly true; a distribution could in principle want to tweak
the default values of any of the sysctl knobs. If we wanted to tweak
anything else in addition to swappiness that I wouldn't have even
bothered to submit the patch since I'll be the first to admit that the
precedent set by further growing the Kconfig phase space is not a
positive one. That being said, swappiness is one of the more significant
knobs in the vm and certainly one of the more likely to be tuned by a
distribution.

> Let's not have the "in short" answer, what's the "long" answer?

See my recent response to Wu Fengguang.

Cheers,

- Ben

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

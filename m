Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 7ADCC8D0030
	for <linux-mm@kvack.org>; Mon,  1 Nov 2010 03:06:37 -0400 (EDT)
Date: Mon, 1 Nov 2010 16:06:27 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [resend][PATCH 2/4] Revert "oom: deprecate oom_adj tunable"
In-Reply-To: <alpine.DEB.2.00.1010261234230.5578@chino.kir.corp.google.com>
References: <20101026220237.B7DA.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1010261234230.5578@chino.kir.corp.google.com>
Message-Id: <20101101030353.607A.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> On Tue, 26 Oct 2010, KOSAKI Motohiro wrote:
> 
> > > NACK as a logical follow-up to my NACK for "oom: remove totalpage 
> > > normalization from oom_badness()"
> > 
> > Huh?
> > 
> > I requested you show us justification. BUT YOU DIDNT. If you have any 
> > usecase, show us RIGHT NOW. 
> > 
> 
> The new tunable added in 2.6.36, /proc/pid/oom_score_adj, is necessary for 
> the units that the badness score now uses.  We need a tunable with a much 

Who we?

> higher resolution than the oom_adj scale from -16 to +15, and one that 
> scales linearly as opposed to exponentially.  Since that tunable is much 
> more powerful than the oom_adj implementation, which never made any real 

The reason that you ware NAKed was not to introduce new powerful feature.
It was caused to break old and used feature from applications.


> sense for defining oom killing priority for any purpose other than 
> polarization, the old tunable is deprecated for two years.

You haven't tested your patch at all. Distro's initram script are using
oom_adj interface and latest kernel show pointless warnings 
"/proc/xx/oom_adj is deprecated, please use /proc/xx/oom_score_adj instead."
at _every_ boot time.

As I said, DON'T SEND UNTESTED PATCH! DON'T BREAK USERLAND CARELESSLY!


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

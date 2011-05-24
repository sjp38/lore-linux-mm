Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id AD8476B0012
	for <linux-mm@kvack.org>; Mon, 23 May 2011 22:01:44 -0400 (EDT)
Date: Tue, 24 May 2011 04:01:35 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: (Short?) merge window reminder
Message-ID: <20110524020135.GA19249@elte.hu>
References: <BANLkTi=PLuZhx1=rCfOtg=aOTuC1UbuPYg@mail.gmail.com>
 <20110523192056.GC23629@elte.hu>
 <BANLkTikdgM+kSvaEYuQkgCYJZELnvwfetg@mail.gmail.com>
 <20110523231721.GM10009@thunk.org>
 <4DDAEC68.30803@zytor.com>
 <BANLkTikGfVSAMY2a2yiXaNpvBVvF8YdMEA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <BANLkTikGfVSAMY2a2yiXaNpvBVvF8YdMEA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Ted Ts'o <tytso@mit.edu>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-arch@vger.kernel.org, DRI <dri-devel@lists.freedesktop.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@suse.de>


* Linus Torvalds <torvalds@linux-foundation.org> wrote:

> Another advantage of switching numbering models (ie 3.0 instead of
> 2.8.x) would be that it would also make the "odd numbers are also
> numbers" transition much more natural.

Yeah, it sounds really good to get rid of the (meanwhile) meaningless
"2.6." prefix from our version code and iterate it in a more
meaningful way.

I suspect the stable team and distros will enjoy the more meaningful
third digit as well: it will raise the perceived importance of
stabilization and packaging work.

Btw., we should probably remove the fourth (patch) level, otherwise
distros might feel tempted to fill it in with their own patch-stack
version number, which would result in confusing "3.3.1.5" meaning
different things on different distros - while 3.3.1-5.rpm style of
distro kernel package naming denotes the distro patch level more
clearly.

I don't think the odd/even history will linger too long: in practice
we'll iterate through 3.1, 3.2, 3.3 and 3.4 rather quickly, in the first
year, so any residual notion of stable/unstable will be gone within a
few iterations.

> Because of our historical even/odd model, I wouldn't do a 2.7.x -
> there's just too much history of 2.1, 2.3, 2.5 being development
> trees. But if I do 3.0, then I'd be chucking that whole thing out the
> window, and the next release would be 3.1, 3.2, etc..
> 
> And then in another few years (probably before getting close to 3.40,
> so I'm not going to make a big deal of 3 = "third decade"), I'd just
> do 4.0 etc.

Perhaps we could do 4.0 once the last bit of -rt hits upstream? /me ducks

> Because all our releases are supposed to be stable releases these
> days, and if we get rid of one level of numbering, I feel perfectly
> fine with getting rid of the even/odd history too.

They are very stable releases as far as i'm concerned - i can pretty
confidently run and use -rc2 and better kernels on my boxes these days
and could do so for the past few years.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 659CA6B0011
	for <linux-mm@kvack.org>; Tue, 24 May 2011 03:55:50 -0400 (EDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: (Short?) merge window reminder
Date: Tue, 24 May 2011 09:55:42 +0200
References: <BANLkTi=PLuZhx1=rCfOtg=aOTuC1UbuPYg@mail.gmail.com> <4DDAEC68.30803@zytor.com> <BANLkTikGfVSAMY2a2yiXaNpvBVvF8YdMEA@mail.gmail.com>
In-Reply-To: <BANLkTikGfVSAMY2a2yiXaNpvBVvF8YdMEA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <201105240955.43229.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Ted Ts'o <tytso@mit.edu>, Ingo Molnar <mingo@elte.hu>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-arch@vger.kernel.org, DRI <dri-devel@lists.freedesktop.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@suse.de>

On Tuesday 24 May 2011, Linus Torvalds wrote:
> Another advantage of switching numbering models (ie 3.0 instead of
> 2.8.x) would be that it would also make the "odd numbers are also
> numbers" transition much more natural.
> 
> Because of our historical even/odd model, I wouldn't do a 2.7.x -
> there's just too much history of 2.1, 2.3, 2.5 being development
> trees. But if I do 3.0, then I'd be chucking that whole thing out the
> window, and the next release would be 3.1, 3.2, etc..

I like that. While I don't really care if you call it 2.7, 2.8 or 3.0
(or 4.0 even, if you want to keep continuity following .38 and .39),
the current 2.5/2.6 numbering cycle is almost 10 years old and has
obviously lost all significance.

The only reason I can see that would make it worthwhile waiting for
is if the enterprise and embedded people were to decide on a common
longterm kernel and call that e.g. 2.7.x or 2.8.x while you continue with
2.9.x or 3.0.x or 3.x. My impression is however that the next longterm
release is still one or two years away, so probably not worth waiting
for and hard to estimate in advance.

> Because all our releases are supposed to be stable releases these
> days, and if we get rid of one level of numbering, I feel perfectly
> fine with getting rid of the even/odd history too.

We still have stable and unstable releases, except that you call the
unstable ones -rcX and they are all nice and short, unlike the infamous
2.1.xxx series ;-)

IMHO simply changing the names from 2.6.40-rcX to 2.7.X and from
2.6.40.X to 2.6.8.X etc would be the most straightforward change
if you want to save the 3.0 release for a special moment.

Enough bike shedding from my side, please just make a decision.

	Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

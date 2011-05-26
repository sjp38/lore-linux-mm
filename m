Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 01A446B0011
	for <linux-mm@kvack.org>; Thu, 26 May 2011 12:38:10 -0400 (EDT)
Message-ID: <4DDE81F4.8060800@panasas.com>
Date: Thu, 26 May 2011 19:38:12 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
Subject: Re: (Short?) merge window reminder
References: <BANLkTi=PLuZhx1=rCfOtg=aOTuC1UbuPYg@mail.gmail.com>	<20110523192056.GC23629@elte.hu>	<BANLkTikdgM+kSvaEYuQkgCYJZELnvwfetg@mail.gmail.com>	<BANLkTinbrtzY66p+1NALP8BDfjXLx=Qp-A@mail.gmail.com>	<4DDD0E5F.5080105@panasas.com> <BANLkTi=FAwzW+qR+Cbwmor90pgbgzfuw-g@mail.gmail.com>
In-Reply-To: <BANLkTi=FAwzW+qR+Cbwmor90pgbgzfuw-g@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Luck <tony.luck@intel.com>
Cc: Alexey Zaytsev <alexey.zaytsev@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-arch@vger.kernel.org, DRI <dri-devel@lists.freedesktop.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@suse.de>

On 05/26/2011 01:21 AM, Tony Luck wrote:
> On Wed, May 25, 2011 at 7:12 AM, Boaz Harrosh <bharrosh@panasas.com> wrote:
>> So if you combine all the above:
>>
>> D. Y. N
>> D - Is the decade since birth (1991 not 1990)
>> Y - is the year in the decade so you have 3.1.x, 3.2.x, .. 3.10.x, 4.1.X and so on
>>    Nice incremental number.
>> N - The Linus release of this Year. So this 3rd one goes up to 4 most probably.
>>
>> Linus always likes, and feels very poetic about the Christmas version release.
>> He hates it when once it slipped into the next year. So now he gets to increment
>> the second digit as a bonus.
>>
>> The 2nd digit gets to start on a *one*, never zero and goes up to *10*, to symbolize
>> the 1991 birth. And we never have .zero quality, right?
>>
>> The first Digit gets incremented on decade from 1991 so on 2011 and not 2010
> 
> This is clearly the best suggestion so far - small numbers, somewhat
> date related (but without stuffing a "2011." on the front).  No ".0"
> releases, ever.
> 
> But best of all it defines now when we will switch to 4.x.y and 5.x.y
> so we don't have to keep having this discussion whenever someone thinks
> that the numbers are getting "too big" (well perhaps when we get to the
> tenth decade or so :-)
> 
> So the only thing left to argue is whether the upcoming release should
> be numbered "3.1.1" as the first release in the first year of the 3rd
> decade ...  or whether we should count 2.6.37 .. 2.6.39 as the first
> three releases this year and thus we ought to start with "3.1.4" (so we
> start with "pi"!).
> 

Yes, Yes I like this a lot. I love pi, thanks.

Boaz
> Linus: If you go with this, you should let Boaz set the new "NAME"
> as a prize for such an inspired solution.
> 
> -Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 9662A6B0011
	for <linux-mm@kvack.org>; Tue, 24 May 2011 14:55:43 -0400 (EDT)
Date: Tue, 24 May 2011 11:55:27 -0700 (PDT)
From: david@lang.hm
Subject: Re: (Short?) merge window reminder
In-Reply-To: <20110524183405.GA14493@citd.de>
Message-ID: <alpine.DEB.2.02.1105241147150.23692@asgard.lang.hm>
References: <BANLkTi=PLuZhx1=rCfOtg=aOTuC1UbuPYg@mail.gmail.com> <20110523192056.GC23629@elte.hu> <BANLkTikdgM+kSvaEYuQkgCYJZELnvwfetg@mail.gmail.com> <20110524183405.GA14493@citd.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthias Schniedermeyer <ms@citd.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-arch@vger.kernel.org, DRI <dri-devel@lists.freedesktop.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@suse.de>

On Tue, 24 May 2011, Matthias Schniedermeyer wrote:

> On 23.05.2011 13:33, Linus Torvalds wrote:
>> On Mon, May 23, 2011 at 12:20 PM, Ingo Molnar <mingo@elte.hu> wrote:
>>>
>>> I really hope there's also a voice that tells you to wait until .42 before
>>> cutting 3.0.0! :-)
>>
>> So I'm toying with 3.0 (and in that case, it really would be "3.0",
>> not "3.0.0" - the stable team would get the third digit rather than
>> the fourth one.
>
> What about strictly 3 part versions? Just add a .0.
>
> 3.0.0 - Release Kernel 3.0
> 3.0.1 - Stable 1
> 3.0.2 - Stable 2
> 3.1.0 - Release Kernel 3.1
> 3.1.1 - Stable 1
> ...
>
> Biggest problem is likely version phobics that get pimples when they see
> trailing zeros. ;-)

since there are always issues discovered with a new kernel is released 
(which is why the -stable kernels exist), being wary of .0 kernels is not 
neccessarily a bad thing.

I still think a date based approach would be the best.

since people are worried about not knowing when a final release will 
happen, base the date on when the merge window opened or closed (always 
known at the time of the first -rc kernel)

in the thread on lwn, people pointed out that the latest 2.6.32 kernel 
would still be a 2009.12.X which doesn't reflect the fact that it was 
released this month. My suggestion for that is to make the X be the number 
of months (or years.months if you don't like large month values) between 
the merge window and the release of the -stable release. This would lead 
to a small problem when there are multiple -stable releases in a month, 
but since that doesn't last very long I don't see a real problem with just 
incramenting the month into the future in those cases.

David Lang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

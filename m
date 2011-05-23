Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 368626B0012
	for <linux-mm@kvack.org>; Mon, 23 May 2011 16:52:16 -0400 (EDT)
Received: by qwa26 with SMTP id 26so4374574qwa.14
        for <linux-mm@kvack.org>; Mon, 23 May 2011 13:52:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <BANLkTikdgM+kSvaEYuQkgCYJZELnvwfetg@mail.gmail.com>
References: <BANLkTi=PLuZhx1=rCfOtg=aOTuC1UbuPYg@mail.gmail.com>
	<20110523192056.GC23629@elte.hu>
	<BANLkTikdgM+kSvaEYuQkgCYJZELnvwfetg@mail.gmail.com>
Date: Tue, 24 May 2011 00:52:14 +0400
Message-ID: <BANLkTinbrtzY66p+1NALP8BDfjXLx=Qp-A@mail.gmail.com>
Subject: Re: (Short?) merge window reminder
From: Alexey Zaytsev <alexey.zaytsev@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Ingo Molnar <mingo@elte.hu>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-arch@vger.kernel.org, DRI <dri-devel@lists.freedesktop.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@suse.de>

On Tue, May 24, 2011 at 00:33, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
> On Mon, May 23, 2011 at 12:20 PM, Ingo Molnar <mingo@elte.hu> wrote:
>>
>> I really hope there's also a voice that tells you to wait until .42 before
>> cutting 3.0.0! :-)
>
> So I'm toying with 3.0 (and in that case, it really would be "3.0",
> not "3.0.0" - the stable team would get the third digit rather than
> the fourth one.
>
> But no, it wouldn't be for 42. Despite THHGTTG, I think "40" is a
> fairly nice round number.
>
> There's also the timing issue - since we no longer do version numbers
> based on features, but based on time, just saying "we're about to
> start the third decade" works as well as any other excuse.
>
> But we'll see.

Maybe, 2011.x, or 11.x, x increasing for every merge window started this year?
This would better reflect the steady nature of the releases, but would
certainly break a lot of scripts. ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

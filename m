Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id ED3C95F0001
	for <linux-mm@kvack.org>; Sat, 30 May 2009 16:52:59 -0400 (EDT)
Received: by bwz21 with SMTP id 21so9092808bwz.38
        for <linux-mm@kvack.org>; Sat, 30 May 2009 13:53:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4A21999E.5050606@redhat.com>
References: <20090528090836.GB6715@elte.hu>
	 <20090530075033.GL29711@oblivion.subreption.com>
	 <4A20E601.9070405@cs.helsinki.fi>
	 <20090530082048.GM29711@oblivion.subreption.com>
	 <20090530173428.GA20013@elte.hu>
	 <20090530180333.GH6535@oblivion.subreption.com>
	 <20090530182113.GA25237@elte.hu>
	 <20090530184534.GJ6535@oblivion.subreption.com>
	 <20090530190828.GA31199@elte.hu> <4A21999E.5050606@redhat.com>
Date: Sat, 30 May 2009 23:53:47 +0300
Message-ID: <84144f020905301353y2f8c232na4c5f9dfb740eec4@mail.gmail.com>
Subject: Re: [patch 0/5] Support for sanitization flag in low-level page
	allocator
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Ingo Molnar <mingo@elte.hu>, "Larry H." <research@subreption.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@osdl.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, pageexec@freemail.hu, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi Rik,

On Sat, May 30, 2009 at 11:39 PM, Rik van Riel <riel@redhat.com> wrote:
>>> Have you benchmarked the addition of these changes? I would like to see
>>> benchmarks done for these (crypto api included), since you are proposing
>>> them.
>>
>> You have it the wrong way around. _You_ have the burden of proof here
>> really, you are trying to get patches into the upstream kernel. I'm not
>> obliged to do your homework for you. I might be wrong, and you can prove me
>> wrong.
>
> Larry's patches do not do what you propose they
> should do, so why would he have to benchmark your
> idea?

It's pretty damn obvious that Larry's patches have a much bigger
performance impact than using kzfree() for selected parts of the
kernel. So yes, I do expect him to benchmark and demonstrate that
kzfree() has _performance problems_ before we can look into merging
his patches.

                                     Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

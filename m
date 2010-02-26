Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 402C76B0047
	for <linux-mm@kvack.org>; Fri, 26 Feb 2010 04:26:44 -0500 (EST)
Received: by bwz19 with SMTP id 19so5872568bwz.6
        for <linux-mm@kvack.org>; Fri, 26 Feb 2010 01:26:41 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <201002252104.51187.rjw@sisk.pl>
References: <9b2b86521001020703v23152d0cy3ba2c08df88c0a79@mail.gmail.com>
	 <201002242152.55408.rjw@sisk.pl>
	 <9b2b86521002250510m75c8b314o37388a04b53a2b67@mail.gmail.com>
	 <201002252104.51187.rjw@sisk.pl>
Date: Fri, 26 Feb 2010 09:26:37 +0000
Message-ID: <9b2b86521002260126g5acabb79uae961dd8668b3c09@mail.gmail.com>
Subject: Re: s2disk hang update
From: Alan Jenkins <sourcejedi.lkml@googlemail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: Mel Gorman <mel@csn.ul.ie>, hugh.dickins@tiscali.co.uk, Pavel Machek <pavel@ucw.cz>, pm list <linux-pm@lists.linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, Kernel Testers List <kernel-testers@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On 2/25/10, Rafael J. Wysocki <rjw@sisk.pl> wrote:
> On Thursday 25 February 2010, Alan Jenkins wrote:
>> On 2/24/10, Rafael J. Wysocki <rjw@sisk.pl> wrote:
>> > On Wednesday 24 February 2010, Alan Jenkins wrote:
> ...
>>
>> > -	while (to_free_normal > 0 && to_free_highmem > 0) {
>> > +	while (to_free_normal > 0 || to_free_highmem > 0) {
>>
>> Yes, that seems to do it.  No more hangs so far (and I can still
>> reproduce the hang with too many applications if I un-apply the
>> patch).
>
> OK, great.  Is this with or without the NOIO-enforcing patch?

With.

>> I did see a non-fatal allocation failure though, so I'm still not sure
>> that the current implementation is strictly correct.
>>
>> This is without the patch to increase "to_free_normal".  If I get the
>> allocation failure again, should I try testing the "free 20% extra"
>> patch?
>
> Either that or try to increase SPARE_PAGES.  That should actually work with
> the last patch applied. :-)
>
> Rafael

<grin>, OK.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

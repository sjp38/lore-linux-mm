Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 6AA0B900086
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 12:32:54 -0400 (EDT)
Date: Fri, 15 Apr 2011 19:28:24 +0300
From: Phil Carmody <ext-phil.2.carmody@nokia.com>
Subject: Re: [PATCH 0/1] mm: make read-only accessors take const pointer
	parameters
Message-ID: <20110415162824.GF7112@esdhcp04044.research.nokia.com>
References: <1302861377-8048-1-git-send-email-ext-phil.2.carmody@nokia.com> <20110415145133.GO15707@random.random> <20110415155916.GD7112@esdhcp04044.research.nokia.com> <op.vtzly7dk3l0zgt@mnazarewicz-glaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <op.vtzly7dk3l0zgt@mnazarewicz-glaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ext Michal Nazarewicz <mina86@mina86.com>
Cc: ext Andrea Arcangeli <aarcange@redhat.com>, akpm@linux-foundation.org, cl@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 15/04/11 18:12 +0200, ext Michal Nazarewicz wrote:
> On Fri, 15 Apr 2011 17:59:16 +0200, Phil Carmody wrote:
>> I'm just glad this wasn't an insta-nack, as I am quite a fan of
>> consts, and hopefully something can be worked out.
>
> I feel you man.  Unfortunately, I think that const, since it's an
> after-thought, is not very usable in C.
>
> For instance, as you've pointed in your patch, the "_ro" suffix
> is sort of dumb, but without it compound_head would have to take
> const and return non-const (like strchr() does) which is kinda
> stupid as well.
>
> What's more, because of lack of encapsulation, a??const struct pagea??
> only means that the object is const but thighs it points to aren't.
> As such, const does not really play that well with structs anyway.

I'm very glad you've mentioned that point, I forgot to. I've taken
the view that in the absense of inside knowledge, const should be
inherited down all pointers. So not only will I not change you, but
I will not change anything you point to. No hidden side effects of
any kind. That reduces where it can be used, but is a much stronger
statement when it can be made.

> const is, in my opinion, one of those things C++ actually got
> right (or close to right).

I shouldn't be seen to agree with you on that, lest any fellow Nokians
notice that I've implied something positive about C++ after my rant on
our core chat channel a few days back. ;-)

Cheers,
Phil

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

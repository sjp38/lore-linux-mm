Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id 306F06B00EA
	for <linux-mm@kvack.org>; Wed, 18 Apr 2012 16:07:52 -0400 (EDT)
Date: Wed, 18 Apr 2012 21:10:32 +0100
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [NEW]: Introducing shrink_all_memory from user space
Message-ID: <20120418211032.47b243da@pyramind.ukuu.org.uk>
In-Reply-To: <CAFLxGvz5tmEi-39CZbJN+0zNd3ZpHXzZcNSFUpUWS_aMDJ4t6Q@mail.gmail.com>
References: <1334483226.20721.YahooMailNeo@web162003.mail.bf1.yahoo.com>
	<CAFLxGvwJCMoiXFn3OgwiX+B50FTzGZmo6eG3xQ1KaPsEVZVA1g@mail.gmail.com>
	<1334490429.67558.YahooMailNeo@web162006.mail.bf1.yahoo.com>
	<CAFLxGvz5tmEi-39CZbJN+0zNd3ZpHXzZcNSFUpUWS_aMDJ4t6Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: richard -rw- weinberger <richard.weinberger@gmail.com>
Cc: PINTU KUMAR <pintu_agarwal@yahoo.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "pintu.k@samsung.com" <pintu.k@samsung.com>

On Sun, 15 Apr 2012 14:10:00 +0200
richard -rw- weinberger <richard.weinberger@gmail.com> wrote:

> On Sun, Apr 15, 2012 at 1:47 PM, PINTU KUMAR <pintu_agarwal@yahoo.com> wrote:
> > Moreover, this is mainly meant for mobile phones where there is only *one* user.
> 
> I see. Jet another awful hack.
> Mobile phones are nothing special. They are computers

Correct - so if it is showing up useful situations then they are also
useful beyond mobile phone.

> Every program which is allowed to use this interface will (ab)use it.

If you expose it to userspace then you would want it very tightly
controlled and very much special case. Within the kernel using it
internally within things like CMA allocators seems to make more sense.

I think you overestimate the abuse. It's an interface which pushes clean
pages that can be cheaply recovered out of memory. It doesn't guarantee
the caller reaps the benefit of that, and the vm will continue to try and
share out any new resource fairly.

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

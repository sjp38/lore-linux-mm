Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 3CAED6B00A0
	for <linux-mm@kvack.org>; Sat, 30 May 2009 03:35:21 -0400 (EDT)
Received: by fxm12 with SMTP id 12so8993274fxm.38
        for <linux-mm@kvack.org>; Sat, 30 May 2009 00:35:53 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090528125042.28c2676f@lxorguk.ukuu.org.uk>
References: <20090520183045.GB10547@oblivion.subreption.com>
	 <4A15A8C7.2030505@redhat.com> <20090522073436.GA3612@elte.hu>
	 <20090522113809.GB13971@oblivion.subreption.com>
	 <20090523124944.GA23042@elte.hu> <4A187BDE.5070601@redhat.com>
	 <20090527223421.GA9503@elte.hu>
	 <20090528072702.796622b6@lxorguk.ukuu.org.uk>
	 <20090528090836.GB6715@elte.hu>
	 <20090528125042.28c2676f@lxorguk.ukuu.org.uk>
Date: Sat, 30 May 2009 10:35:53 +0300
Message-ID: <84144f020905300035g1d5461f9n9863d4dcdb6adac0@mail.gmail.com>
Subject: Re: [patch 0/5] Support for sanitization flag in low-level page
	allocator
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Ingo Molnar <mingo@elte.hu>, Rik van Riel <riel@redhat.com>, "Larry H." <research@subreption.com>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@osdl.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, pageexec@freemail.hu, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi Alan,

On Thu, May 28, 2009 at 2:50 PM, Alan Cox <alan@lxorguk.ukuu.org.uk> wrote:
> The performance cost of such a security action are NIL when the feature
> is disabled. So the performance cost in the general case is irrelevant.
>
> If you need this kind of data wiping then the performance hit
> is basically irrelevant, the security comes first. You can NAK it all you
> like but it simply means that such users either have to apply patches or
> run something else.
>
> If it harmed general user performance you'd have a point - but its like
> SELinux you don't have to use it if you don't need the feature. Which it
> must be said is a lot better than much of the scheduler crud that has
> appeared over time which you can't make go away.

The GFP_SENSITIVE flag looks like a big hammer that we don't really
need IMHO. It seems to me that most of the actual call-sites (crypto
code, wireless keys, etc.) should probably just use kzfree()
unconditionally to make sure we don't leak sensitive data. I did not
look too closely but I don't think any of the sensitive kfree() calls
are in fastpaths so the performance impact is negligible.

                                Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

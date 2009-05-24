Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 5C4E46B004F
	for <linux-mm@kvack.org>; Sun, 24 May 2009 12:38:45 -0400 (EDT)
Date: Sun, 24 May 2009 09:38:51 -0700
From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: [PATCH] Support for unconditional page sanitization
Message-ID: <20090524093851.37cbb4d6@infradead.org>
In-Reply-To: <4A191F44.24468.2C006647@pageexec.freemail.hu>
References: <20090520183045.GB10547@oblivion.subreption.com>
	<20090523182141.GK13971@oblivion.subreption.com>
	<20090523140509.5b4a59e4@infradead.org>
	<4A191F44.24468.2C006647@pageexec.freemail.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: pageexec@freemail.hu
Cc: "Larry H." <research@subreption.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Ingo Molnar <mingo@elte.hu>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@osdl.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>
List-ID: <linux-mm.kvack.org>

On Sun, 24 May 2009 12:19:48 +0200
pageexec@freemail.hu wrote:

> On 23 May 2009 at 14:05, Arjan van de Ven wrote:
> 
> > On Sat, 23 May 2009 11:21:41 -0700
> > "Larry H." <research@subreption.com> wrote:
> > 
> > > +static inline void sanitize_highpage(struct page *page)
> > 
> > any reason we're not reusing clear_highpage() for this?
> > (I know it's currently slightly different, but that is fixable)
> 
> KM_USER0 users are not supposed to be called from soft/hard irq
> contexts for high memory pages, something that cannot be guaranteed
> at this low level of page freeing (i.e., we could be interrupting
> a clear_highmem and overwrite its KM_USER0 mapping, leaving it dead
> in the water when we return there). in other words, sanitization
> must be able to nest within KM_USER*, so that pretty much calls for
> its own slot.

no arguement that current clear_highpage isn't a fit. I was more
thinking about using the content of sanitize_highpage(), and just
calling that clear_highpage(). (or in other words, improve
clear_highpage to be usable in more situations)


-- 
Arjan van de Ven 	Intel Open Source Technology Centre
For development, discussion and tips for power savings, 
visit http://www.lesswatts.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

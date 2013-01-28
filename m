Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id 53B126B0009
	for <linux-mm@kvack.org>; Sun, 27 Jan 2013 22:44:55 -0500 (EST)
Received: by mail-da0-f41.google.com with SMTP id e20so1040416dak.28
        for <linux-mm@kvack.org>; Sun, 27 Jan 2013 19:44:54 -0800 (PST)
Date: Sun, 27 Jan 2013 19:44:56 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 7/11] ksm: make KSM page migration possible
In-Reply-To: <1359333683.6763.13.camel@kernel>
Message-ID: <alpine.LNX.2.00.1301271936071.896@eggly.anvils>
References: <alpine.LNX.2.00.1301251747590.29196@eggly.anvils> <alpine.LNX.2.00.1301251802050.29196@eggly.anvils> <1359265635.6763.0.camel@kernel> <alpine.LNX.2.00.1301271506480.17495@eggly.anvils> <1359333683.6763.13.camel@kernel>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Simon Jeons <simon.jeons@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Petr Holasek <pholasek@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Izik Eidus <izik.eidus@ravellosystems.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sun, 27 Jan 2013, Simon Jeons wrote:
> On Sun, 2013-01-27 at 15:12 -0800, Hugh Dickins wrote:
> > On Sat, 26 Jan 2013, Simon Jeons wrote:
> > > 
> > > Could you explain why need check page->mapping twice after get page?
> > 
> > Once for the !locked case, which should not return page if mapping changed.
> > Once for the locked case, which should not return page if mapping changed.
> > We could use "else", but that wouldn't be an improvement.
> 
> But for locked case, page->mapping will be check twice.

Thrice.

I'm beginning to wonder: you do realize that page->mapping is volatile,
from the point of view of get_ksm_page()?  That is the whole point of
why get_ksm_page() exists.

I can see that the word "volatile" is not obviously used here - it's
tucked away inside the ACCESS_ONCE() - but I thought the descriptions
of races and barriers made that obvious.

If the comments here haven't helped enough, please take a look at
git commit 4035c07a8959 "ksm: take keyhole reference to page".

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

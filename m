Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id 2E0FF8D0001
	for <linux-mm@kvack.org>; Fri, 11 May 2012 12:54:41 -0400 (EDT)
Received: by wefh52 with SMTP id h52so806499wef.14
        for <linux-mm@kvack.org>; Fri, 11 May 2012 09:54:39 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CA+1xoqc15HY1rECsJ6Aj1WMzwT12z4DByJhFopyBAiKawEFh3Q@mail.gmail.com>
References: <alpine.LSU.2.00.1205110054520.2801@eggly.anvils>
 <CA+1xoqcChazS=TRt6-7GjJAzQNFLFXmO623rWwjRkdD5x3k=iw@mail.gmail.com>
 <4FACD00D.4060003@kernel.org> <4FACD573.4060103@kernel.org>
 <CA+55aFxsZqU4bXRz61ngnR2ozH=AAhwGHR+PqzdTRfnCxJY0oQ@mail.gmail.com> <CA+1xoqc15HY1rECsJ6Aj1WMzwT12z4DByJhFopyBAiKawEFh3Q@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 11 May 2012 09:54:18 -0700
Message-ID: <CA+55aFztbcB1sULup-rCsWmOaC7RFLvuJ=sqGQz=SAKzys02mw@mail.gmail.com>
Subject: Re: [PATCH] mm: raise MemFree by reverting percpu_pagelist_fraction
 to 0
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <levinsasha928@gmail.com>
Cc: Minchan Kim <minchan@kernel.org>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, May 11, 2012 at 9:35 AM, Sasha Levin <levinsasha928@gmail.com> wrote:
>
> Once it's on, we reserve 1/x of the pages for the pagelists. I'm not
> sure why 8 was selected in the first place, but I guess it made sense
> that you don't want to reserve 15%+ of your memory for the pagelists.

Why not just accept any number, but turn small numbers into the minimum?

And if it's a per-cpu, then the minimum had better depend on number of
CPU's anyway. 15% of memory on a single-cpu already sounds insanely
high, but if you have several cpu's, it's going to be just totally
crazy.

So a minimum of 8 already sounds broken. Exposing that minimum in a
way that makes it impossible to reset it sounds just insane.

                    Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

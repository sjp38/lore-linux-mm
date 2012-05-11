Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id EA7468D0001
	for <linux-mm@kvack.org>; Fri, 11 May 2012 12:27:59 -0400 (EDT)
Received: by wefh52 with SMTP id h52so784162wef.14
        for <linux-mm@kvack.org>; Fri, 11 May 2012 09:27:58 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4FACD573.4060103@kernel.org>
References: <alpine.LSU.2.00.1205110054520.2801@eggly.anvils>
 <CA+1xoqcChazS=TRt6-7GjJAzQNFLFXmO623rWwjRkdD5x3k=iw@mail.gmail.com>
 <4FACD00D.4060003@kernel.org> <4FACD573.4060103@kernel.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 11 May 2012 09:27:37 -0700
Message-ID: <CA+55aFxsZqU4bXRz61ngnR2ozH=AAhwGHR+PqzdTRfnCxJY0oQ@mail.gmail.com>
Subject: Re: [PATCH] mm: raise MemFree by reverting percpu_pagelist_fraction
 to 0
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sasha Levin <levinsasha928@gmail.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, May 11, 2012 at 2:01 AM, Minchan Kim <minchan@kernel.org> wrote:
>
> I didn't have a time so made quick patch to show just concept.
> Not tested and Not consider carefully.
> If anyone doesn't oppose, I will send formal patch which will have more beauty code.

What's so magical about that '8' *anyway*? We do we have that minimum at all?

At the very least, the 8-vs-0 thing needs to be explained.

                   Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

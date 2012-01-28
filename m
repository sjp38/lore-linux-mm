Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id BD4D16B004D
	for <linux-mm@kvack.org>; Fri, 27 Jan 2012 22:33:10 -0500 (EST)
Received: by dake40 with SMTP id e40so2410212dak.14
        for <linux-mm@kvack.org>; Fri, 27 Jan 2012 19:33:09 -0800 (PST)
Date: Fri, 27 Jan 2012 19:32:49 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: kernel bug: mmap, XIP, page faults, multiple threads
In-Reply-To: <CAEMjCzJ0JD58xrtPD6DZQbBTwLwcfUphRi+vFUn=nu69s8zH9Q@mail.gmail.com>
Message-ID: <alpine.LSU.2.00.1201271837350.3731@eggly.anvils>
References: <CAEMjCzJ0JD58xrtPD6DZQbBTwLwcfUphRi+vFUn=nu69s8zH9Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Louis Alex Eisner <leisner@cs.ucsd.edu>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@kernel.dk>, linux-mm@kvack.org, Carsten Otte <cotte@de.ibm.com>

On Thu, 26 Jan 2012, Louis Alex Eisner wrote:
> 
>    I hope I'm sending this to the right people, but I wasn't sure who to
> send it to, since I'm not entirely sure exactly where the bug lives.
>  Without further ado:
> 
> Summary:
> When multiple threads simultaneously attempt to write to the same page of a
> file which has been mmapped using XIP for the first time, an unhandled
> EBUSY signal causes the kernel to panic.

Thanks a lot for your report, and all the info you carefully gathered.

I confess that I haven't looked at it at all!  Because I was thinking
maybe I should take a look, and when did we last hear from Carsten?
And though I now see more recent postings from him in other fields,
what came first to my eye was this nugget below.

It was white-space-damaged and wouldn't apply (I bet that's why it
got lost), so I've fixed that up and reformatted the description,
and added you as a Reporter - but otherwise it's as Carsten posted.

Hugh

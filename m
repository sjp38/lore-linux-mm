Received: by uproxy.gmail.com with SMTP id o2so23410uge
        for <linux-mm@kvack.org>; Tue, 21 Mar 2006 21:37:55 -0800 (PST)
Message-ID: <bc56f2f0603212137s727ff0edu@mail.gmail.com>
Date: Wed, 22 Mar 2006 00:37:54 -0500
From: "Stone Wang" <pwstone@gmail.com>
Subject: Re: [PATCH][5/8] proc: export mlocked pages info through "/proc/meminfo: Wired"
In-Reply-To: <442098B6.5000607@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
References: <bc56f2f0603200537i7b2492a6p@mail.gmail.com>
	 <441FEFC7.5030109@yahoo.com.au>
	 <bc56f2f0603210733vc3ce132p@mail.gmail.com>
	 <442098B6.5000607@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: akpm@osdl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The name "Wired" could be changed to which one most kids think better
fits the job.

I choosed "Wired" for:
"Locked" will conflict with PG_locked bit of a pags.
"Pinned" indicates a short-term lock,so not fits the job too.

Shaoping Wang

2006/3/21, Nick Piggin <nickpiggin@yahoo.com.au>:
> Stone Wang wrote:
> > The list potentially could have more wider use.
> >
> > For example, kernel-space locked/pinned pages could be placed on the list too
> > (while mlocked pages are locked/pinned by system calls from user-space).
> >
>
> kernel-space pages are always pinned. And no, you can't put them on the list
> because you never know if their ->lru field is going to be used for something
> else.
>
> Why would you want to ever do something like that though? I don't think you
> should use this name "just in case", unless you have some really good
> potential usage in mind.
>
> ---
> SUSE Labs, Novell Inc.
> Send instant messages to your online friends http://au.messenger.yahoo.com
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

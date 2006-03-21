Received: by uproxy.gmail.com with SMTP id m3so701785uge
        for <linux-mm@kvack.org>; Tue, 21 Mar 2006 07:33:39 -0800 (PST)
Message-ID: <bc56f2f0603210733vc3ce132p@mail.gmail.com>
Date: Tue, 21 Mar 2006 10:33:36 -0500
From: "Stone Wang" <pwstone@gmail.com>
Subject: Re: [PATCH][5/8] proc: export mlocked pages info through "/proc/meminfo: Wired"
In-Reply-To: <441FEFC7.5030109@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
References: <bc56f2f0603200537i7b2492a6p@mail.gmail.com>
	 <441FEFC7.5030109@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: akpm@osdl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The list potentially could have more wider use.

For example, kernel-space locked/pinned pages could be placed on the list too
(while mlocked pages are locked/pinned by system calls from user-space).

2006/3/21, Nick Piggin <nickpiggin@yahoo.com.au>:
> Stone Wang wrote:
> > Export mlock(wired) info through file /proc/meminfo.
> >
>
> If wired is solely for mlock pages... why not just call it
> mlock/mlocked?
>
> --
> SUSE Labs, Novell Inc.
>
> Send instant messages to your online friends http://au.messenger.yahoo.com
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

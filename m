Message-ID: <442098B6.5000607@yahoo.com.au>
Date: Wed, 22 Mar 2006 11:22:14 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH][5/8] proc: export mlocked pages info through "/proc/meminfo:
 Wired"
References: <bc56f2f0603200537i7b2492a6p@mail.gmail.com>	 <441FEFC7.5030109@yahoo.com.au> <bc56f2f0603210733vc3ce132p@mail.gmail.com>
In-Reply-To: <bc56f2f0603210733vc3ce132p@mail.gmail.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Stone Wang <pwstone@gmail.com>
Cc: akpm@osdl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Stone Wang wrote:
> The list potentially could have more wider use.
> 
> For example, kernel-space locked/pinned pages could be placed on the list too
> (while mlocked pages are locked/pinned by system calls from user-space).
> 

kernel-space pages are always pinned. And no, you can't put them on the list
because you never know if their ->lru field is going to be used for something
else.

Why would you want to ever do something like that though? I don't think you
should use this name "just in case", unless you have some really good
potential usage in mind.

---
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

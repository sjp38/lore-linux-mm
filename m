Message-ID: <4420FB66.3090206@yahoo.com.au>
Date: Wed, 22 Mar 2006 18:23:18 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH][5/8] proc: export mlocked pages info through "/proc/meminfo:
 Wired"
References: <bc56f2f0603200537i7b2492a6p@mail.gmail.com>	 <441FEFC7.5030109@yahoo.com.au>	 <bc56f2f0603210733vc3ce132p@mail.gmail.com>	 <442098B6.5000607@yahoo.com.au> <bc56f2f0603212137s727ff0edu@mail.gmail.com>
In-Reply-To: <bc56f2f0603212137s727ff0edu@mail.gmail.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Stone Wang <pwstone@gmail.com>
Cc: akpm@osdl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Stone Wang wrote:
> The name "Wired" could be changed to which one most kids think better
> fits the job.
> 
> I choosed "Wired" for:
> "Locked" will conflict with PG_locked bit of a pags.
> "Pinned" indicates a short-term lock,so not fits the job too.
> 

Err we're going around in circles here. This tangent started because
I suggested that you could call them "mlock" or "mlocked".

But don't get too hung up on the naming. I pointed out quite a lot
of much more fundamental problems.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

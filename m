Subject: Re: [PATCH][5/8] proc: export mlocked pages info through
	"/proc/meminfo: Wired"
From: Arjan van de Ven <arjan@infradead.org>
In-Reply-To: <bc56f2f0603212137s727ff0edu@mail.gmail.com>
References: <bc56f2f0603200537i7b2492a6p@mail.gmail.com>
	 <441FEFC7.5030109@yahoo.com.au> <bc56f2f0603210733vc3ce132p@mail.gmail.com>
	 <442098B6.5000607@yahoo.com.au>
	 <bc56f2f0603212137s727ff0edu@mail.gmail.com>
Content-Type: text/plain
Date: Wed, 22 Mar 2006 10:04:23 +0100
Message-Id: <1143018264.2955.47.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Stone Wang <pwstone@gmail.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, akpm@osdl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2006-03-22 at 00:37 -0500, Stone Wang wrote:
> The name "Wired" could be changed to which one most kids think better
> fits the job.
> 
> I choosed "Wired" for:
> "Locked" will conflict with PG_locked bit of a pags.
> "Pinned" indicates a short-term lock,so not fits the job too.

pinned does not imply short term

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

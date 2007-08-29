Date: Wed, 29 Aug 2007 07:30:40 -0700
From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: speeding up swapoff
Message-ID: <20070829073040.1ec35176@laptopd505.fenrus.org>
In-Reply-To: <1188394172.22156.67.camel@localhost>
References: <1188394172.22156.67.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Drake <ddrake@brontes3d.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 29 Aug 2007 09:29:32 -0400
Daniel Drake <ddrake@brontes3d.com> wrote:


Hi,

> I've spent some time trying to understand why swapoff is such a slow
> operation.
> 
> My experiments show that when there is not much free physical memory,
> swapoff moves pages out of swap at a rate of approximately 5mb/sec.

sounds like about disk speed (at random-seek IO pattern)


> I'm happy to spend a few more hours looking into implementing this but
> would greatly appreciate any advice from those in-the-know on if my
> ideas are broken to start with...

before you go there... is this a "real life" problem? Or just a
mostly-artificial corner case? (the answer to that obviously is
relevant for the 'should we really care' question)

Another question, if this is during system shutdown, maybe that's a
valid case for flushing most of the pagecache first (from userspace)
since most of what's there won't be used again anyway. If that's enough
to make this go faster...

A third question, have you investigated what happens if a process gets
killed that has pages in swap; as long as we don't page those in but
just forget about them, that would solve the shutdown problem nicely
(since we kill stuff first anyway there)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

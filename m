Date: Thu, 3 Aug 2000 13:22:26 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: RFC: design for new VM
In-Reply-To: <Pine.LNX.4.21.0008031512390.24022-100000@duckman.distro.conectiva>
Message-ID: <Pine.LNX.4.10.10008031316490.6528-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>


On Thu, 3 Aug 2000, Rik van Riel wrote:
> 
> The lists are not at all dependant on where the pages come
> from. The lists are dependant on the *page age*. This almost
> sounds like you didn't read my mail... ;(

I did read the email. And I understand that. And that's exactly why I
think a single-list is equivalent (because your lists basically act simply
as "caches" of the page age).

> NO. We need different queues so waiting for pages to be flushed
> to disk doesn't screw up page aging of the other pages (the ones
> we absolutely do not want to evict from memory yet).

Ehh.. Did you read _my_ mail?

Go back. Read it. Realize that your "multiple queues" is nothing more than
"cached information". They do not change _behaviour_ at all. They only
change the amount of CPU-time you need to parse it.

Your arguments do not seem to address this issue at all.

In my mailbox I have an email from you as of yesterday (or the day before)
which says:
 - I will not try to balance the current MM because it is not doable

And I don't see that your suggestion is fundamentally adding anything but
a CPU timesaver.

Basically, answer me this _simple_ question: what _behavioural_
differences do you claim multiple queues have? Ignore CPU usage for now. 

I'm claiming they are just a cache.

And you claim that the current MM cannot be balanced, but your new one
can.

Please reconcile these two things for me.

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

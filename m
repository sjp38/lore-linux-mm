Date: Tue, 20 May 2008 19:33:22 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: 2.6.25.1: Kernel BUG at mm/rmap.c:669, General Protection Faults,
 and generic hard locks
In-Reply-To: <8347f3fb0805200756q294b08b7jff3dfbb8345d004b@mail.gmail.com>
Message-ID: <Pine.LNX.4.64.0805201919420.3783@blonde.site>
References: <8347f3fb0805111721m57ba99e4l21df02d38ca3f41f@mail.gmail.com>
 <8347f3fb0805121555k266fab9fvf9d006ab2a89dd7a@mail.gmail.com>
 <Pine.LNX.4.64.0805161110210.565@blonde.site>
 <8347f3fb0805200756q294b08b7jff3dfbb8345d004b@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Randy Johnson <theraptor2005@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 20 May 2008, Randy Johnson wrote:
> 
> I did manage to steal another complete set of RAM and swapped it in,
> with no change. This still doesn't rule out potential issues with the
> MB (slots or controller); I've got a spare board coming in in the next
> week.

That does indeed reduce the likelihood that it's a hardware issue.

> In the mean time, I've been busy bisecting this one down.
> Unfortunately, it takes a good hour or two of heavy load to trigger
> sometimes, and I've got a good 15000 or so commits to get through, so
> it could still be a while.

If it is bisectable (rather than just taking much longer to go wrong
sometimes than others, so you never know when to say "good" or "bad"),
then that is well worth doing, from my point of view: thank you for
taking the trouble to do so.  But keep an open mind: if it really is
down to a hardware issue of some kind, it may turn out to be a waste
of your time, even though potentially helpful to me.

> I haven't been keeping any traces from
> these, even if I could get them (which typically I can't). Would they
> still be useful even if they're from random commits?

They might be: the more information you can give us the better.
So if you do get something interesting in the logs, please do send
it over, with a note of the head commit at that point.  Please then
also send your .config, and which version of compiler you're using.

Thanks,
Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

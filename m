Date: Thu, 29 Apr 1999 10:27:09 -0400 (EDT)
From: "Benjamin C.R. LaHaise" <blah@kvack.org>
Subject: Re: Hello
In-Reply-To: <v04020a01b34cd7f3c7c3@[198.115.92.60]>
Message-ID: <Pine.LNX.3.95.990429102031.23110B-100000@as200.spellcast.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "James E. King, III" <jking@ariessys.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 28 Apr 1999, James E. King, III wrote:

> 1. If I purchase a Quad Xeon 550 with 4 GB of memory, will Linux work on it?
>    (I saw the whole thing about tweaking kernel parameters to change from a 3:1
>     split to a 2:2 split)
>    Should I just buy 2GB - will I be able to use the extra 2GB?

You won't be able to use the extra 2GB without some effort.  Current plans
seem to be headed towards keeping the current 3G/1G split.  Fwiw, if
you're going to spend that much money, why not purchase an Alpha?  That
way you'll be able to grow beyond the 4GB as your data grows.

> 2. Can I create a large (let's say 1GB) ramdisk or memory filesystem?

I think someone created patches that make a ramdisk out of the really high
memory.  Try doing a search of the linux-kernel archives -- I remember
seeing it withing the past 3 or 4 months.  Hope this helps!

		-ben

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/

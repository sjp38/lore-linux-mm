Date: Thu, 3 Aug 2000 15:19:45 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: RFC: design for new VM
In-Reply-To: <Pine.LNX.4.21.0008031850330.24022-100000@duckman.distro.conectiva>
Message-ID: <Pine.LNX.4.10.10008031513490.6698-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

[ Ok, we agree on the basics ]

On Thu, 3 Aug 2000, Rik van Riel wrote:
> 
> What I fail to see is why this would be preferable to a code
> base where all the different pages are neatly separated and
> we don't have N+1 functions that are all scanning the same
> list, special-casing out each other's pages and searching 
> the list for their own special pages...

I disagree just with the "all improved, radically new, 50% more for the
same price" ad-campaign I've seen.

I don't like the fact that you said that you don't want to worry about
2.4.x because you don't think it can be fixed it as it stands. I think
that's a cop-out and dishonest. I think I've explained why.

I could fully imagine doing even multi-lists in 2.4.x. I think performance
bugs are secondary to stability bugs, but hey, if the patch is clean and
straightforward and fixes a performance bug, I would not hesitate to apply
it. It may be that going to multi-lists actually is easier just because of
some thins being more explicit. Fine.

But stop the ad-campaign. We get too many biased ads for presidents-to-be
already, no need to take that approach to technical issues. We need to fix
the VM balancing, we don't need to sell it to people with buzz-words.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

Received: from neon.transmeta.com (neon-best.transmeta.com [206.184.214.10])
	by kvack.org (8.8.7/8.8.7) with ESMTP id UAA13810
	for <linux-mm@kvack.org>; Tue, 17 Nov 1998 20:42:38 -0500
Date: Tue, 17 Nov 1998 17:41:51 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: useless report -- perhaps memory allocation problems in 2.1.12[678]
In-Reply-To: <Pine.LNX.3.95.981117171051.1077V-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.3.95.981117174031.23128A-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Rik van Riel <H.H.vanRiel@phys.uu.nl>, Jeffrey Hundstad <jeffrey.hundstad@mankato.msus.edu>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>



On Tue, 17 Nov 1998, Linus Torvalds wrote:
> 
> But whether kswapd should go page-synchronous at some point? Maybe. I can
> see arguments both for and against (the "for" argument is that we prefer
> to have more intense bouts of IO followed by a nice clean wait, while the
> "against" argument is that maybe we want to spread out the thing). 

Oh, well, I'm currently leaning for "for", which means your patch to
page_io.c is what I have now.. I don't like "trickling" pages by running
out of requests or something like that, so having the occasional nice wait
is probably best.

		Linus

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org

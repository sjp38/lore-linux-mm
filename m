Received: from neon.transmeta.com (neon-best.transmeta.com [206.184.214.10])
	by kvack.org (8.8.7/8.8.7) with ESMTP id PAA22390
	for <linux-mm@kvack.org>; Tue, 24 Nov 1998 15:49:43 -0500
Date: Tue, 24 Nov 1998 12:45:26 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: Linux-2.1.129..
In-Reply-To: <Pine.LNX.3.96.981124205232.23104B-100000@mirkwood.dummy.home>
Message-ID: <Pine.LNX.3.95.981124124249.6535B-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, "Eric W. Biederman" <ebiederm+eric@ccr.net>, "Dr. Werner Fink" <werner@suse.de>, Kernel Mailing List <linux-kernel@vger.rutgers.edu>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>



On Tue, 24 Nov 1998, Rik van Riel wrote:
> 
> From the discussion we've been having yesterday, I get
> the impression that the ambitious stuff can be added
> little by little, during the lifetime of 2.2, without
> impacting stability or hampering preformance.

I believe that may well be true. I _do_ believe that the MM code actually
has all the basic functionality there, and that the infrastructure is
stable and in place. That helps a lot.

But there may be some unforseen thing that makes it harder than expected
to add a page to the swap cache at write-out rather that page-in. The
patches may be trivial, in which case I will certainly apply them, because
I do believe that it's the RightThing(tm) to do, but if it turns out to be
nontrivial due to some unforseen circumstance.. 

		Linus

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org

Received: from neon.transmeta.com (neon-best.transmeta.com [206.184.214.10])
	by kvack.org (8.8.7/8.8.7) with ESMTP id CAA05473
	for <linux-mm@kvack.org>; Sun, 23 May 1999 02:03:40 -0400
Date: Sat, 22 May 1999 23:03:00 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [PATCHES]
In-Reply-To: <m1r9o8sbiu.fsf@flinx.ccr.net>
Message-ID: <Pine.LNX.3.95.990522225849.31920C-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm+eric@ccr.net>
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, MOLNAR Ingo <mingo@chiara.csoma.elte.hu>
List-ID: <linux-mm.kvack.org>


On 22 May 1999, Eric W. Biederman wrote:
>
> 	I've been busy working to improve the basic mechanisms of the
> page cache, and finally what appears to be a stable set of patches, with
> no hacks against 2.3.3

I have three worries:
 - this is large, with no input from anybody else that I have seen.
 - I absolutely detest getting encoded patches. It makes it much harder
   for me to just quickly look them over for an immediate feel for what
   they look like.
 - Ingo just did the page cache / buffer cache dirty stuff, this is going
   to clash quite badly with his changes I suspect.

So would you mind just sending the patches in plaintext, one by one, to
avoid at least one of my worries (and as a reference to other people: this
is basicall yhow I always prefer patches). 

The other worries I'll see about later. The short descriptions sound fine,
although I still want to look at the vm_store part closer..

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/

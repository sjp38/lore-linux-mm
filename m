Received: from alogconduit1ah.ccr.net (root@alogconduit1al.ccr.net [208.130.159.12])
	by kvack.org (8.8.7/8.8.7) with ESMTP id KAA09796
	for <linux-mm@kvack.org>; Sun, 23 May 1999 10:52:24 -0400
Subject: Re: [PATCHES]
References: <Pine.LNX.3.95.990522225849.31920C-100000@penguin.transmeta.com>
From: ebiederm+eric@ccr.net (Eric W. Biederman)
Date: 23 May 1999 09:54:53 -0500
In-Reply-To: Linus Torvalds's message of "Sat, 22 May 1999 23:03:00 -0700 (PDT)"
Message-ID: <m1k8tzsuo1.fsf@flinx.ccr.net>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, MOLNAR Ingo <mingo@chiara.csoma.elte.hu>
List-ID: <linux-mm.kvack.org>

>>>>> "LT" == Linus Torvalds <torvalds@transmeta.com> writes:

LT> On 22 May 1999, Eric W. Biederman wrote:
>> 
>> I've been busy working to improve the basic mechanisms of the
>> page cache, and finally what appears to be a stable set of patches, with
>> no hacks against 2.3.3

LT> I have three worries:
LT>  - this is large, with no input from anybody else that I have seen.

Not much.  I had aggreements in principal but no one else has looked at it
real hard.

LT>  - I absolutely detest getting encoded patches. It makes it much harder
LT>    for me to just quickly look them over for an immediate feel for what
LT>    they look like.
O.k.  I do that for large patches because I'm paranoid about the mailers
in between. . .

LT>  - Ingo just did the page cache / buffer cache dirty stuff, this is going
LT>    to clash quite badly with his changes I suspect.

Interesting.  I have been telling folks I've been working on this for quite
a while.    I wish I'd heard about him or vis versa.

Ingo can I get a pointer to your work?


Linus, I'll be resending the patches later today (church is in about 5 minutes).

LT> The other worries I'll see about later. The short descriptions sound fine,

Cool.  If you agree with my work in principal, that makes life easier.
Now I just need to worry about the details of my patches.

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/

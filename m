Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id PAA24458
	for <linux-mm@kvack.org>; Thu, 19 Nov 1998 15:37:28 -0500
Date: Thu, 19 Nov 1998 21:05:35 +0100 (CET)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Re: Two naive questions and a suggestion
In-Reply-To: <19981119002037.1785.qmail@sidney.remcomp.fr>
Message-ID: <Pine.LNX.3.96.981119210154.16706B-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: jfm2@club-internet.fr
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 19 Nov 1998 jfm2@club-internet.fr wrote:

> 1) Is there any text describing memory management in 2.1?  (Forgive me
>    if I missed an obvious URL)

Not yet, I really should be working on that (the code
seems to have stabilized now)...

> 2) Are there plans for implementing the swapping of whole processes a
>    la BSD?

Yes, there are plans. The plans are quite detailed too, but
I think I haven't put them up on my home page yet.

> Suggestion: Given that the requiremnts for a workstation (quick
> response) are different than for a server (high throughput) it could
> make sense to allow the user either use /proc for selecting the VM
> policy or have a form of loadable VM manager.  Or select it at
> compile time. 

There are quite a lot of things you can tune in /proc,
I don't know if you have read the documentation, but
if you start trying things you'll be amazed hom much
you can change the system's behaviour with the existing
controls.

Btw, since you are so enthusiastic about documentation,
would you be willing to help me write it?

cheers,

Rik -- slowly getting used to dvorak kbd layout...
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org

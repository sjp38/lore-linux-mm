Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id OAA02292
	for <linux-mm@kvack.org>; Thu, 26 Nov 1998 14:02:43 -0500
Date: Thu, 26 Nov 1998 13:18:34 +0100 (CET)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Re: Two naive questions and a suggestion
In-Reply-To: <19981125103132.H350@uni-koblenz.de>
Message-ID: <Pine.LNX.3.96.981126131619.711C-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: ralf@uni-koblenz.de
Cc: jfm2@club-internet.fr, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 25 Nov 1998 ralf@uni-koblenz.de wrote:
> On Tue, Nov 24, 1998 at 09:44:32PM -0000, jfm2@club-internet.fr wrote:
> 
> > In situation like those above I would like Linux supported a concept
> > like guaranteed processses: if VM is exhausted by one of them then try
> > to get memory by killing non guaranteed processes and only kill the
> > original one if all reamining survivors are guaranteed ones.
> > It would be better for mission critical tasks.
> 
> Long time ago I suggested to make it configurable whether a process
> gets memory which might be overcommited or not.  This leaves
> malloc(x) == NULL to deal with and that's a userland problem anyway. 

Then what would you do when your 250MB non-overcommitting
program needs to do a fork() in order to call /usr/bin/lpr?

Install an extra 250MB of swap? I don't think so :)
These are the situations where sane people want overcommit.

regards,

Rik -- who actually has 250MB of extra swap...
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org

Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id OAA19706
	for <linux-mm@kvack.org>; Fri, 19 Jun 1998 14:39:15 -0400
Date: Fri, 19 Jun 1998 19:06:08 +0200 (CEST)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Re: New Linux-MM homepage
In-Reply-To: <m1lnqtwgxc.fsf@flinx.npwt.net>
Message-ID: <Pine.LNX.3.96.980619190100.7276A-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm+eric@npwt.net>
Cc: Rik van Riel <H.H.vanRiel@phys.uu.nl>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On 19 Jun 1998, Eric W. Biederman wrote:
> >>>>> "RR" == Rik van Riel <H.H.vanRiel@phys.uu.nl> writes:
> 
> RR> You can find it on:  <http://www.phys.uu.nl/~riel/mm-patch/>
> 
>  * The current code also has some small bugs regarding page aging and administration of
>    shared pages; they are scanned multiple times and we sometimes loose track of them. ->
>    Vnodes & shmfs.
> 
> Q: We loose track of shared pages?  I'm not aware of this, could I get
> a better description.

Well, there are several cases where we 'forget' about
shared area's. One of them is where SysV shared memory
is unmapped from all processes but the handle remains.
Since we do page scanning by process, we can't find
such an area. I don't know if this has been fixed by
now, but I certainly remember the messages about it...

> Suggestion:
> We might possibly want to include on the developers page everyone's
> email address, and then on the suggestions page just link back to the
> developers page...

OK, I'll do that.

> Thanks for writing documentation.  I am really bad at doing that.

"To teach is to learn twice" I'm not a very productive
programmer yet, I don't even do a CS study. By writing
docs, I get to think about things more and as a result
I am becoming a better programmer.

Also, I really like it when people can actually use
the code we're writing. We don't _just_ write it for
fun...

Rik.
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+

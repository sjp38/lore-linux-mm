Received: from flinx.npwt.net (eric@flinx.npwt.net [208.236.161.237])
	by kvack.org (8.8.7/8.8.7) with ESMTP id LAA18802
	for <linux-mm@kvack.org>; Fri, 19 Jun 1998 11:23:32 -0400
Subject: Re: New Linux-MM homepage
References: <Pine.LNX.3.96.980619141537.6318A-100000@mirkwood.dummy.home>
From: ebiederm+eric@npwt.net (Eric W. Biederman)
Date: 19 Jun 1998 10:27:11 -0500
In-Reply-To: Rik van Riel's message of Fri, 19 Jun 1998 14:17:55 +0200 (CEST)
Message-ID: <m1lnqtwgxc.fsf@flinx.npwt.net>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Cc: Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

>>>>> "RR" == Rik van Riel <H.H.vanRiel@phys.uu.nl> writes:

RR> Hi,
RR> I've written a new, more structured and more complete
RR> Linux MM homepage. It's not finished yet, but I need
RR> the input of you guys to make it better...

RR> You can find it on:  <http://www.phys.uu.nl/~riel/mm-patch/>

RR> TIA for suggestions,

 * The current code also has some small bugs regarding page aging and administration of
   shared pages; they are scanned multiple times and we sometimes loose track of them. ->
   Vnodes & shmfs.

Q: We loose track of shared pages?  I'm not aware of this, could I get
a better description.

Suggestion:
We might possibly want to include on the developers page everyone's
email address, and then on the suggestions page just link back to the
developers page...

Also,
Thanks for writing documentation.  I am really bad at doing that.

Eric

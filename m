Received: from max.fys.ruu.nl (max.fys.ruu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id TAA19720
	for <linux-mm@kvack.org>; Thu, 26 Feb 1998 19:23:15 -0500
Date: Fri, 27 Feb 1998 00:29:44 +0100 (MET)
From: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Subject: Re: memory limitation test kit (tm) :-)
In-Reply-To: <199802262253.WAA03955@dax.dcs.ed.ac.uk>
Message-ID: <Pine.LNX.3.91.980227002715.6476A-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>
Cc: linux-mm <linux-mm@kvack.org>, werner@suse.de
List-ID: <linux-mm.kvack.org>

On Thu, 26 Feb 1998, Stephen C. Tweedie wrote:

> > I've made a 'very preliminary' test patch to test
> > whether memory limitation / quotation might work.
> 
> Running a single task which has a perfectly reasonable resident set
> larger than num_physpages/2 will thrash unnecessarily.

I know... The patch was just meant as a "look it works ...
euhm, nope" type of eye-opener. Once the swap cache and
inactive list infrastructure is in place, we should replace
RSS limit with active limit, ie. the maximum number of active
pages a process is allowed to have. Then we can do effective
and harmless RSS limitation.

Rik.
+-----------------------------+------------------------------+
| For Linux mm-patches, go to | "I'm busy managing memory.." |
| my homepage (via LinuxHQ).  | H.H.vanRiel@fys.ruu.nl       |
| ...submissions welcome...   | http://www.fys.ruu.nl/~riel/ |
+-----------------------------+------------------------------+

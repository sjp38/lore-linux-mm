Received: from max.fys.ruu.nl (max.fys.ruu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id LAA08340
	for <linux-mm@kvack.org>; Thu, 26 Feb 1998 11:13:32 -0500
Date: Thu, 26 Feb 1998 16:32:04 +0100 (MET)
From: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Subject: Re: memory limitation test kit (tm) :-)
In-Reply-To: <Pine.LNX.3.91.980226135506.30101A-100000@mirkwood.dummy.home>
Message-ID: <Pine.LNX.3.91.980226162810.943C-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>
Cc: linux-mm <linux-mm@kvack.org>, werner@suse.de, Rogier Wolff <R.E.Wolff@BitWizard.nl>
List-ID: <linux-mm.kvack.org>

On Thu, 26 Feb 1998, Rik van Riel wrote:

> I've made a 'very preliminary' test patch to test
> whether memory limitation / quotation might work.
> It's untested, untunable and plain wrong, but nevertheless
> I'd like you all to take a look at it and point out things
> that I've forgotten in the limitation code...

Hate to follow up on my own posts, but as Rogier illustrated
nicely it just won't work...
Hell, I even tested it, naturally with the same result as
Rogier's post illustrated :-))

An all-new stripped down version of my mmap-age patch is
on my way to Linus, Stephen and linux-mm however.

Rik.
+-----------------------------+------------------------------+
| For Linux mm-patches, go to | "I'm busy managing memory.." |
| my homepage (via LinuxHQ).  | H.H.vanRiel@fys.ruu.nl       |
| ...submissions welcome...   | http://www.fys.ruu.nl/~riel/ |
+-----------------------------+------------------------------+

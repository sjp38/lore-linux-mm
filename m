Date: Thu, 26 Feb 1998 23:49:02 +0100 (MET)
From: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Subject: Re: Fairness in love and swapping
In-Reply-To: <199802262233.WAA03878@dax.dcs.ed.ac.uk>
Message-ID: <Pine.LNX.3.91.980226234621.5141A-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>
Cc: Rogier Wolff <R.E.Wolff@BitWizard.nl>, torvalds@transmeta.com, blah@kvack.org, nahshon@actcom.co.il, alan@lxorguk.ukuu.org.uk, paubert@iram.es, linux-kernel@vger.rutgers.edu, mingo@chiara.csoma.elte.hu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 26 Feb 1998, Stephen C. Tweedie wrote:

> > What we really need is that some mechanism that actually determines
> > in the first and last case that the system is thrashing like hell,
> > and that "swapping" (as opposed to paging) is becoming a required
> > strategy. 
> 
> True.  Any takers for this?  :)

Yup. Here's one :-)

I've got the NetBSD source (with comments dating back
to '84 and possibly before :-) and parts of the Digital
Unix system administators tuning guide next to me, so
I have some idea as to what to do...

But still, we need to come up with a general idea of
the algorithms first (if you don't believe this, take
a look at my memory-limit patch earlier today..).

Rik.
+-----------------------------+------------------------------+
| For Linux mm-patches, go to | "I'm busy managing memory.." |
| my homepage (via LinuxHQ).  | H.H.vanRiel@fys.ruu.nl       |
| ...submissions welcome...   | http://www.fys.ruu.nl/~riel/ |
+-----------------------------+------------------------------+

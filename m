Date: Thu, 26 Feb 1998 15:30:25 +0100 (MET)
From: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Subject: Re: Fairness in love and swapping
In-Reply-To: <199802260805.JAA00715@cave.BitWizard.nl>
Message-ID: <Pine.LNX.3.91.980226152230.878A-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Rogier Wolff <R.E.Wolff@BitWizard.nl>
Cc: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>, torvalds@transmeta.com, blah@kvack.org, nahshon@actcom.co.il, alan@lxorguk.ukuu.org.uk, paubert@iram.es, linux-kernel@vger.rutgers.edu, mingo@chiara.csoma.elte.hu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 26 Feb 1998, Rogier Wolff wrote:

>           0        50           51      100
>       P1  <in memory>...........<in memory> 
> 
>           0          1        50           51      100
>       P2  ...........<in memory>...........<in memory> 

Now, how do we select which processes to suspend temporarily
and which to wake up again...
Suspending X wouldn't be to good, since then a lot of other
procesess would block on it... But this gives us a good clue
as to what to do.

We could:
- force-swap out processes which have slept for some time
- suspend & force-swap out the largest process
- wake it up again when there are two proceses waiting on
  it (to prevent X from being swapped out)
- wake up the suspended process after some time (2 seconds
  per megabyte size?) and mark the process as just-suspended
  (and don't swap it out again for a guaranteed 1 second *
  megabyte size period)
- if necessary, suspend & swap another large process when
  we're short on memory again

Doing this together with a dynamic RSS-limit strategy and
page cache page aging might give us quite an improvement
in VM performance.

Of course, I'm quite sure that I forgot something,
so please comment on how/what you want things changed.

Rik.
+-----------------------------+------------------------------+
| For Linux mm-patches, go to | "I'm busy managing memory.." |
| my homepage (via LinuxHQ).  | H.H.vanRiel@fys.ruu.nl       |
| ...submissions welcome...   | http://www.fys.ruu.nl/~riel/ |
+-----------------------------+------------------------------+

Date: Thu, 26 Feb 1998 22:41:26 GMT
Message-Id: <199802262241.WAA03911@dax.dcs.ed.ac.uk>
From: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: Fairness in love and swapping
In-Reply-To: <Pine.LNX.3.91.980226152230.878A-100000@mirkwood.dummy.home>
References: <199802260805.JAA00715@cave.BitWizard.nl>
	<Pine.LNX.3.91.980226152230.878A-100000@mirkwood.dummy.home>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Cc: Rogier Wolff <R.E.Wolff@BitWizard.nl>, "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>, torvalds@transmeta.com, blah@kvack.org, nahshon@actcom.co.il, alan@lxorguk.ukuu.org.uk, paubert@iram.es, linux-kernel@vger.rutgers.edu, mingo@chiara.csoma.elte.hu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Thu, 26 Feb 1998 15:30:25 +0100 (MET), Rik van Riel
<H.H.vanRiel@fys.ruu.nl> said:

> Now, how do we select which processes to suspend temporarily
> and which to wake up again...
> Suspending X wouldn't be to good, since then a lot of other
> procesess would block on it... But this gives us a good clue
> as to what to do.

> We could:
> - force-swap out processes which have slept for some time
> - suspend & force-swap out the largest process
> - wake it up again when there are two proceses waiting on
>   it (to prevent X from being swapped out)

Define the number of processes waiting on a given process?

Another way of making the distinction between batch and interactive
processes might be to observe that interactive processes spend some of
their time in "S" (interruptible sleep) state, whereas we expect
compute-bound jobs to be in "R" or "D" state most of the time.
However, that breaks down too when you consider batch jobs involving
pipelines, such as gcc -pipe.

> Doing this together with a dynamic RSS-limit strategy and
> page cache page aging might give us quite an improvement
> in VM performance.

Yes, and doing streamed writeahead and clustered swapin will up the
throughput to/from swap quite significantly too.

Cheers,
 Stephen.

Date: Mon, 23 Feb 1998 15:27:13 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: PATCH: Swap shared pages (was: How to read-protect a vm_area?)
In-Reply-To: <199802232317.XAA06136@dax.dcs.ed.ac.uk>
Message-ID: <Pine.LNX.3.95.980223152519.418B-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>
Cc: "Benjamin C.R. LaHaise" <blah@kvack.org>, Rik van Riel <H.H.vanRiel@fys.ruu.nl>, Itai Nahshon <nahshon@actcom.co.il>, Alan Cox <alan@lxorguk.ukuu.org.uk>, paubert@iram.es, linux-kernel@vger.rutgers.edu, Ingo Molnar <mingo@chiara.csoma.elte.hu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>



On Mon, 23 Feb 1998, Stephen C. Tweedie wrote:
> 
> The patch below, against 2.1.88, adds a bunch of new functionality to
> the swapper.  The main changes are:

Ok, this looks clean, I've applied it to my current sources and pending no
surprises it will be in 89. 

[ I've also changed the way we consider us to need more memory in kswapd,
  but that was entirely orthogonal and did not impact these patches. ]

Knock wood,

		Linus

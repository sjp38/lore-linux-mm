Date: Thu, 26 Feb 1998 22:33:28 GMT
Message-Id: <199802262233.WAA03878@dax.dcs.ed.ac.uk>
From: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: Fairness in love and swapping
In-Reply-To: <199802260805.JAA00715@cave.BitWizard.nl>
References: <199802252032.UAA01920@dax.dcs.ed.ac.uk>
	<199802260805.JAA00715@cave.BitWizard.nl>
Sender: owner-linux-mm@kvack.org
To: Rogier Wolff <R.E.Wolff@BitWizard.nl>
Cc: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>, torvalds@transmeta.com, blah@kvack.org, H.H.vanRiel@fys.ruu.nl, nahshon@actcom.co.il, alan@lxorguk.ukuu.org.uk, paubert@iram.es, linux-kernel@vger.rutgers.edu, mingo@chiara.csoma.elte.hu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Thu, 26 Feb 1998 09:05:55 +0100 (MET), R.E.Wolff@BitWizard.nl
(Rogier Wolff) said:

> [ Processes P1 and P2 both need the same amount of CPU time, I've noted
> the "completion percentages" at the top. ]

> If you run it like this, you'll get:

>           0        50       100
>       P1  <---- in memory ----> 

>           0                   5         50      100
>       P2  < swapping like mad ><---- in memory ---> 

> but if the system would be "fair" we would get: 

>           0                  5                 10            15
>       P1  <------ swapping --- like --- mad ------------------- ....

>           0                  5                 10            15
>       P2  <------ swapping --- like --- mad ------------------- ....


> So.... In some cases, this behaviour is exactly what you want. 

It's maybe not "exactly what you want", but it can certainly be better
than being purely fair, for exactly this reason.  That's why it's hard
to see how we can improve much on the current scheme except to tweak
around the edges --- there are cases where being completely fair
actually reduces overall throughput substantially.

> What we really need is that some mechanism that actually determines
> in the first and last case that the system is thrashing like hell,
> and that "swapping" (as opposed to paging) is becoming a required
> strategy. 

True.  Any takers for this?  :)

--Stephen

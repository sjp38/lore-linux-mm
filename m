Date: Tue, 3 Mar 1998 23:54:16 GMT
Message-Id: <199803032354.XAA02829@dax.dcs.ed.ac.uk>
From: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: [uPATCH] small kswapd improvement ???
In-Reply-To: <Pine.LNX.3.91.980303180022.414A-100000@mirkwood.dummy.home>
References: <Pine.LNX.3.91.980303180022.414A-100000@mirkwood.dummy.home>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Cc: Linus Torvalds <torvalds@transmeta.com>, "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>, "Benjamin C.R. LaHaise" <blah@kvack.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, 3 Mar 1998 18:05:18 +0100 (MET), Rik van Riel
<H.H.vanRiel@fys.ruu.nl> said:

> Hi,
> I remember the 1.1 or 1.2 days when Stephen reworked the
> swap code and I played around with a small piece of
> vmscan.c. Back then a simple bug was encountered and 'fixed'
> by always starting the memory scan at adress 0, which gives
> a highly unfair and inefficient aging process.

Ouch --- I wonder how much this is hurting 2.0.33.  I think I'll have
to try that, and perhaps look at this for 2.0.34/LMP... 

Thanks,
 Stephen.

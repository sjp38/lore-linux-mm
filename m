Date: Sat, 22 Sep 2001 00:09:54 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: broken VM in 2.4.10-pre9
In-Reply-To: <Pine.GSO.4.21.0109212151590.9760-100000@weyl.math.psu.edu>
Message-ID: <Pine.LNX.4.33L.0109212351160.19147-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alexander Viro <viro@math.psu.edu>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Daniel Phillips <phillips@bonn-fries.net>, Rob Fuller <rfuller@nsisoftware.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 21 Sep 2001, Alexander Viro wrote:

> It means that you prefer system dying under much lighter load.  At
> some point any box will get into feedback loop,

> The question being, at which point will it happen and how graceful
> will the degradation be when we get near that point.

And ... what do we do when we reach that point ?

It's obvious that we need load control to make the machine
survive at that point; load control is a horrible measure
which will make interactivity very bad, but will cause the
box to survive where otherwise it would be thrashing.

Having a better paging system would mean having the 'thrashing
point' (where we need to kick in load control' much further
out and being able to keep the system behave better under
heavier VM loads.

regards,

Rik
-- 
IA64: a worthy successor to i860.

http://www.surriel.com/		http://distro.conectiva.com/

Send all your spam to aardvark@nl.linux.org (spam digging piggy)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

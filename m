Date: Sat, 4 Aug 2001 23:39:46 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [RFC] Accelerate dbench
In-Reply-To: <01080504334100.00294@starship>
Message-ID: <Pine.LNX.4.33L.0108042338130.2526-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@bonn-fries.net>
Cc: linux-mm@kvack.org, Marcelo Tosatti <marcelo@conectiva.com.br>
List-ID: <linux-mm.kvack.org>

On Sun, 5 Aug 2001, Daniel Phillips wrote:

> -  	SetPageReferenced(page);
> +	if (PageActive(page))
> +	  	SetPageReferenced(page);
> +	else
> +		activate_page(page);
>
> So I'll try it...<time passes>...OK, it doesn't make a lot of
> difference, results still range from "pretty good" to "really
> great".  Not really suprising, I have this growing gut feeling
> that we're not doing that well on the active page aging anyway,

Yes, I have the feeling that exponential down aging wasn't
such a good idea in combination with the fact that most of
the access bits are "hidden" in page tables ...

> and that random selection of candidates for trial on the
> inactive queue would perform almost as well - which might be
> worth testing.  Anyway, I'm putting this on the back burner for
> now.  Interesting as it is, it's hardly a burning issue.

Well, we found that doing instant activation gives a huge
performance increase. That's one important point already ;)

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

Received: from burns.conectiva (burns.conectiva [10.0.0.4])
	by perninha.conectiva.com.br (Postfix) with SMTP id D782938D9D
	for <linux-mm@kvack.org>; Tue, 16 Jul 2002 15:36:41 -0300 (EST)
Date: Tue, 16 Jul 2002 15:36:23 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [oops] 2.5.25+rmap+OptAwayPTE
In-Reply-To: <1026841535.17328.39.camel@plars.austin.ibm.com>
Message-ID: <Pine.LNX.4.44L.0207161535370.3009-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII
Content-ID: <Pine.LNX.4.44L.0207161535372.3009@duckman.distro.conectiva>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Larson <plars@austin.ibm.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 16 Jul 2002, Paul Larson wrote:

> This is the output from the oops I was getting on the 8-way.  With
> 2.5.25 alone, same configuration it boots fine.  Add the patches and it
> gives me this on boot.  I'll be happy to test any fixes for this or
> additional patches.  Hope this is useful.

Can you get this oops with just 2.5.25 + the minimal
rmap patch from akpm's page ?

http://www.zipworld.com.au/~akpm/linux/patches/2.5/2.5.25/rmap.patch

It might be that this oops happens just with optawaypte...

regards,

Rik
-- 
	http://www.linuxsymposium.org/2002/
"You're one of those condescending OLS attendants"
"Here's a nickle kid.  Go buy yourself a real t-shirt"

http://www.surriel.com/		http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

Received: from burns.conectiva (burns.conectiva [10.0.0.4])
	by perninha.conectiva.com.br (Postfix) with SMTP id 5048B38C22
	for <linux-mm@kvack.org>; Tue,  7 May 2002 16:51:19 -0300 (EST)
Date: Tue, 7 May 2002 16:51:11 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: Why *not* rmap, anyway?
In-Reply-To: <E175Ary-0000Th-00@starship>
Message-ID: <Pine.LNX.4.44L.0205071650170.7447-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@bonn-fries.net>
Cc: Christian Smith <csmith@micromuse.com>, Joseph A Knapka <jknapka@earthlink.net>, "Martin J. Bligh" <Martin.Bligh@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 7 May 2002, Daniel Phillips wrote:

> The most obvious place to start are the page table walking operations,
> of which there are a half-dozen instances or so.  Bill started to do
> some work on this, but that ran aground somehow.  I think you might run
> into the argument 'not broken yet, so don't fix yet'.  Still, it would
> be worth experimenting with strategies.
>
> Personally, I'd consider such work a diversion from the more important
> task of getting rmap implemented.

They're orthagonal.  If we find somebody to implement the
stuff it's easy enough to just merge it everywhere.

In fact, I'm pretty sure that if we get this stuff
abstracted out properly it should be easier to get -rmap
merged and improved.

cheers,

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

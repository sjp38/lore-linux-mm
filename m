Received: from muck.dcs.ed.ac.uk (root@muck.dcs.ed.ac.uk [129.215.160.15])
	by kvack.org (8.8.7/8.8.7) with ESMTP id LAA00541
	for <linux-mm@kvack.org>; Tue, 16 Jun 1998 11:12:46 -0400
Date: Tue, 16 Jun 1998 16:11:53 +0100
Message-Id: <23752.199806161511@canna.dcs.ed.ac.uk>
Subject: Re: TODO list, v0.01
In-Reply-To: <19980615185647.50925@boole.suse.de>
References: <Pine.LNX.3.95.980611235823.21729A-100000@localhost>
	<19980615185647.50925@boole.suse.de>
From: "Stephen Tweedie" <sct@dcs.ed.ac.uk>
Sender: owner-linux-mm@kvack.org
To: "Dr. Werner Fink" <werner@suse.de>
Cc: Linux MM <linux-mm@kvack.org>, "Stephen.Tweedie" <sct@dcs.ed.ac.uk>
List-ID: <linux-mm.kvack.org>

Hi,

In article <19980615185647.50925@boole.suse.de>, "Dr. Werner Fink"
<werner@suse.de> writes:

> On Thu, Jun 11, 1998 at 11:59:45PM +0200, Rik van Riel wrote:
>> 
>> here's the MM TODO list, very first version, just listing
>> the projects people are working on.

> ??? == We should get a better recover time/behaviour of the mm for small
>        systems under high load.  Currently small systems with 2.1.10X
>        (RAM < 32MB, sometimes < 64MB) do loose in comparision to 2.0.33/34.

It's the number one problem we need to fix for 2.2.  Fortunately a lot
of people are aware of the problem and we spent a lot of time talking
about it at expo and Usenix.  I think we've got a good handle on how
to start tackling the obvious problems, but there will still be a lot of
tuning required before we can release a 2.2 kernel and call it stable.

I'll write up an outline of what I think we need to start doing once
I'm back from Usenix.

--Stephen

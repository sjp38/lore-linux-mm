Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id FAA23910
	for <linux-mm@kvack.org>; Mon, 6 Jul 1998 05:09:25 -0400
Date: Mon, 6 Jul 1998 08:32:14 +0200 (CEST)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Re: current VM performance
In-Reply-To: <k27m1sdssq.fsf@zero.aec.at>
Message-ID: <Pine.LNX.3.96.980706083031.3995A-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <ak@muc.de>
Cc: Rik van Riel <H.H.vanRiel@phys.uu.nl>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

On 5 Jul 1998, Andi Kleen wrote:
> Rik van Riel <H.H.vanRiel@phys.uu.nl> writes:
> 
> > I started with a 512x512 image (background of www.zip.com.au)
> > in GIMP. The first thing I did was increasing the image size
> > to 5120x5120, now I am 120M in swap on my 24M machine :-)
> 
> I'm not sure if the gimp is a good vm tester, because it basically
> does its own VM with its tile based memory architecture. 

With some changes to /usr/share/gimp/gimprc it is...
Let it grow to 100MB of memory and use cubic interpolation
instead of linear....

Besides, I don't have room anymore for the gimp's own
swap file :)

Rik.
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org

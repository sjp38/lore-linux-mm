Date: Thu, 29 Apr 1999 14:09:13 -0400 (EDT)
From: "Benjamin C.R. LaHaise" <blah@kvack.org>
Reply-To: "Benjamin C.R. LaHaise" <blah@kvack.org>
Subject: Re: 1GB ramdisk
In-Reply-To: <v04020a00b34e1e944f31@[198.115.92.60]>
Message-ID: <Pine.LNX.3.95.990429105157.23748A-100000@as200.spellcast.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "James E. King, III" <jking@ariessys.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 29 Apr 1999, James E. King, III wrote:

> Someone suggested using alpha which would solve all of my problems.  True,
> but where can I find a quad processor 500MHz alpha box for around $25,000?
> Let me know.  Last time I checked, the list price on an AlphaServer 4100
> configured this way was over $100,000.

I'm going to play a skeptic here as I think Xeons aren't the best use of
people's money, but that's just my opinion.  What are the actual
bottlenecks in your system -- remember that filesystem access and vm
operations are still serialized in 2.2, so going from 2 to 4 cpus may not 
get you the performance improvement you deserved.  A dual processor 21264
box with 512M of RAM goes for ~$15000 (see http://www.dcginc.com/), which 
is worth considering.

		-ben


--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/

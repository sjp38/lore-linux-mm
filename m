Received: from ukaea.org.uk (gateway.ukaea.org.uk [194.128.63.74])
	by kvack.org (8.8.7/8.8.7) with ESMTP id FAA10665
	for <linux-mm@kvack.org>; Fri, 4 Dec 1998 05:42:59 -0500
Message-Id: <98Dec4.104023gmt.66305@gateway.ukaea.org.uk>
Date: Fri, 4 Dec 1998 10:41:15 +0000
From: Neil Conway <nconway.list@ukaea.org.uk>
MIME-Version: 1.0
Subject: Re: SWAP: Linux far behind Solaris or I missed something (fwd)
References: <Pine.LNX.3.96.981203130156.1008D-100000@mirkwood.dummy.home>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Cc: Linux MM <linux-mm@kvack.org>, Jean-Michel.Vansteene@bull.net, "linux-kernel@vger.rutgers.edu" <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> 
> Hi,
> 
> I think we really should be working on this -- anybody
> got a suggestion?
> 
> (although the 2.1.130+my patch seems to work very well
> with extremely high swap throughput)


Since the poster didn't say otherwise, perhaps this test was performed
with buffermem/pagecache.min_percent set to their default values, which
IIRC add up to 13% of physical RAM (in fact that's PHYSICAL ram, not 13%
of available RAM).  So take a 1024MB machine, with (say) roughly 16MB
used by the kernel and kernel-data.  Then subtract 0.13*1024 (133MB !!)
and you're left with a paltry 875MB or so.  (This assumes that the
poster had modified his kernel to handle the full 1024MB btw).

So in fact the cache/buffers probably weren't quite filled to their min.
values or swapping and poor performance would have set in even earlier
than they did (910MB).

It's worth taking note I suppose that Solaris *doesn't* have this
problem.  It's probably not worth a kernel patch to fix the Linux
behaviour though; I just reset the values to more sane ones in rc.local.

Now let's see if Linux does any better with say 2% for each of the min
values...

Neil
PS: to Jean-Michel: in case you don't know what I mean (though I assume
you do), look at /proc/sys/vm/pagecache and buffermem, and
Documentation/sysctl/ 
PPS: I presume that the initial sluggishness of Solaris was due to it
throwing away some cache?


> 
> ---------- Forwarded message ----------
> Date: Wed, 02 Dec 1998 16:49:30 +0100
> From: Jean-Michel VANSTEENE <Jean-Michel.Vansteene@bull.net>
> To: linux-kernel <linux-kernel@vger.rutgers.edu>
> Subject: SWAP: Linux far behind Solaris or I missed something
> 
> I've made some tests to load a computer (1GB memory).
> A litle process starts eating 900 MB then slowly eats
> the remainder of the memory 1MB by 1MB and does a
> "data shake": 200,000 times a memcpy of 4000 bytes
> randomly choosen.
> 
> I want to test the swap capability.
> 
> Solaris was used under XWindow, Linux under text
> console... What do I forget to comfigure or tune?
> Don't let me with such bad values.......
> 
> ------------------------------------------------
> I removed micro seconds displayed by my function
> after call to gettimeofday
> 
> megs    Solaris      Linux
> ------------------------------------------------
> 901:    18 secs      9 secs
> 902:    11 secs      9 secs
> 903:    10 secs      9 secs
> 904:    9 secs       9 secs
> 905:    9 secs       9 secs
> 906:    9 secs       9 secs
> 907:    9 secs       9 secs
> 908:    9 secs       9 secs
> 909:    9 secs       9 secs
> 910:    9 secs       13 secs
> 911:    9 secs       17 secs
> 912:    9 secs       20 secs
> 913:    9 secs       24 secs
> 914:    9 secs       33 secs
> 915:    10 secs      44 secs
> 916:    9 secs       56 secs
> 917:    9 secs       65 secs
> 918:    9 secs       75 secs
> 919:    9 secs       81 secs
> 920:    9 secs       87 secs
> 921:    9 secs       96 secs
> 922:    9 secs       108 secs
> 923:    9 secs       122 secs
> 924:    9 secs       129 secs
> 925:    9 secs       142 secs
> 926:    9 secs       155 secs
> 927:    9 secs       161 secs
> 
> 928 - 977  always  9 secs under solaris
> 
> 978:    10 secs      <stop testing>
> 979:    10 secs       -------
> 980:    11 secs
> 981:    14 secs
> 982:    17 secs
> 983:    21 secs
> 984:    28 secs
> 985:    32 secs
> 986:    26 secs
> 987:    18 secs
> 988:    19 secs
> 989:    24 secs
> 990:    29 secs
> 991:    41 secs
> 992:    48 secs
> 993:    85 secs
> 994:    86 secs
> 995:    91 secs
> 996:    92 secs
> 997:    93 secs
> 998:    97 secs
> 999:    83 secs
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org

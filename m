Date: Mon, 27 Aug 2007 22:53:15 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH/RFC]  Add node 'states' sysfs class attribute - V2
In-Reply-To: <20070827222912.8b364352.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0708272235580.9834@schroedinger.engr.sgi.com>
References: <200708242228.l7OMS5fU017948@imap1.linux-foundation.org>
 <1188248528.5952.95.camel@localhost> <20070827170159.0a79529d.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0708271702520.1787@schroedinger.engr.sgi.com>
 <20070827181405.57a3d8fe.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0708271826180.10344@schroedinger.engr.sgi.com>
 <20070827201822.2506b888.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0708272210210.9748@schroedinger.engr.sgi.com>
 <20070827222912.8b364352.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm <linux-mm@kvack.org>, mel@skynet.ie, y-goto@jp.fujitsu.com, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

On Mon, 27 Aug 2007, Andrew Morton wrote:

> Your claim here is, I believe, that a human user interface should be
> implemented in the kernel because the cost (to you) (short-term) of doing
> that is lower that the cost of implementing a simpler kernel interface and
> a bit of userspace human presentation code.  Even though the long-term
> cost to the kernel maintainers is higher, and the resulting output is
> harder for programs to parse.

The long term cost is zero since there is already a kernel function 
to process these lists. See bitmap_parselist(). The kernel already allows 
output and input of these lists.

> Please type "cat /proc/stat".  The world hasn't ended.

Yea that the prime example of a bad use of the proc filesystem. All these 
numbers better be split up into individual files.

The cpu affinity is a horror to see on 4096 cpu systems. If you 
want to figure out to which cpu the process has restricted itself then you 
need to do some quick hex conversions in your mind.

margin:/proc/1 # cat /proc/1/stat
1 (init) S 0 1 1 0 -1 4194560 77 340052 10 1575 0 463 1256 1246 20 0 1 0 
67 1802240 47 18446744073709551615 4611686018427387904 4611686018428481976 
6953557824659209808 16140902370223191856 11529215046068536865 0 0 
1467013372 680207875 11529215050365063520 0 0 0 2 0 0 0


> > Well I keep ending up cat this and that proc entry for debugging and its 
> > difficult to do if one sysfs file spews huge amounts of illegible binary 
> > data to you.
> 
> Nobody ever said "binary".  Please try to keep up.

What you get right now from this patch is a series of hex digits and you 
have the task of converting that to a series of 0 and 1's in your mind and 
then figure out which node it was that had a 1 there.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

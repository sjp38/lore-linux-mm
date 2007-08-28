Date: Tue, 28 Aug 2007 15:02:14 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH/RFC]  Add node 'states' sysfs class attribute - V2
In-Reply-To: <1188309928.5079.37.camel@localhost>
Message-ID: <Pine.LNX.4.64.0708281458520.17559@schroedinger.engr.sgi.com>
References: <200708242228.l7OMS5fU017948@imap1.linux-foundation.org>
 <1188248528.5952.95.camel@localhost>  <20070827170159.0a79529d.akpm@linux-foundation.org>
  <Pine.LNX.4.64.0708271702520.1787@schroedinger.engr.sgi.com>
 <20070827181405.57a3d8fe.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0708271826180.10344@schroedinger.engr.sgi.com>
 <20070827201822.2506b888.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0708272210210.9748@schroedinger.engr.sgi.com>
 <20070827222912.8b364352.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0708272235580.9834@schroedinger.engr.sgi.com>
 <20070827231214.99e3c33f.akpm@linux-foundation.org> <1188309928.5079.37.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, mel@skynet.ie, y-goto@jp.fujitsu.com, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

On Tue, 28 Aug 2007, Lee Schermerhorn wrote:

> I thought I'd give it a try, but thinking that /proc variables were
> discouraged, where else but sysfs to put them.  A class attribute
> to /sys/devices/system/node seemed like the appropriate place.

Right. That is the right place.

> I'm not wedded to this interface.  However, I realy don't think it's
> worth doing as multiple files.

I think one single file per nodemask makes sense. Otherwise files become 
difficult to parse. I just forgot....

> its executed, in the grand scheme of things.  However, I must admit that
> I've become addicted to the ease with which one can write one-off
> scripts to query configuration/statistics, tune/modify behavior or
> trigger actions via just cat'ing from and/or echo'ing to a /proc or /sys
> file.
> 
> So, where to go with this patch?  Drop it?  Leave it as is?  Move
> it /proc so that it can be a single file?   Make it multiple files in
> sysfs?  Putting it as politely as possible, the last is not my favorite
> option, but if folks think this info is useful and that's the way to go,
> so be it.  And what about mask vs list?  It's a 4 character change in
> the code to go either way.

I would suggest to do the one file thing in sysfs and use the function 
that already exists in the kernel to print the nice nodelists. Using the 
nice function is just calling another function since the code is already 
there.

At some point we may even allow changing the nodemasks. One could imagine 
that we would add nodemasks that allow use of hugepages on certain nodes 
or the slab allocator to allocate on certain nodes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

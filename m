Date: Mon, 27 Aug 2007 18:29:26 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH/RFC]  Add node 'states' sysfs class attribute - V2
In-Reply-To: <20070827181405.57a3d8fe.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0708271826180.10344@schroedinger.engr.sgi.com>
References: <200708242228.l7OMS5fU017948@imap1.linux-foundation.org>
 <1188248528.5952.95.camel@localhost> <20070827170159.0a79529d.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0708271702520.1787@schroedinger.engr.sgi.com>
 <20070827181405.57a3d8fe.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm <linux-mm@kvack.org>, mel@skynet.ie, y-goto@jp.fujitsu.com, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

On Mon, 27 Aug 2007, Andrew Morton wrote:

> > online: 0-1, 3
> 
> really?  with commas and spaces and minus signs and colons?  ug, what next?
> animated ascii art?  This is sysfs, not procfs ;)

The masks can get quite ugly to read if you have lots of nodes. F.e. with 
1024 nodes you get a line that wraps around more than 10 times.

> OK, well if the meminfo file is the only one in there which broke the
> golden rule, I don't think we have sufficient excuse to break it again.
> 
> $ cat  /sys/devices/system/node/possible
> 0-4
> $
> 
> I think a bitmap would be better, personally.
> 
> That in fact makes "possible" unneeded, doesn't it?  It would always be
> all-ones?

There could be the case that nodes 1-9 and 20-29 are possible but 
the ones in between are not available.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

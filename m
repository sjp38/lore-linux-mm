Subject: Re: [PATCH/RFC]  Add node 'states' sysfs class attribute - V2
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20070827231214.99e3c33f.akpm@linux-foundation.org>
References: <200708242228.l7OMS5fU017948@imap1.linux-foundation.org>
	 <1188248528.5952.95.camel@localhost>
	 <20070827170159.0a79529d.akpm@linux-foundation.org>
	 <Pine.LNX.4.64.0708271702520.1787@schroedinger.engr.sgi.com>
	 <20070827181405.57a3d8fe.akpm@linux-foundation.org>
	 <Pine.LNX.4.64.0708271826180.10344@schroedinger.engr.sgi.com>
	 <20070827201822.2506b888.akpm@linux-foundation.org>
	 <Pine.LNX.4.64.0708272210210.9748@schroedinger.engr.sgi.com>
	 <20070827222912.8b364352.akpm@linux-foundation.org>
	 <Pine.LNX.4.64.0708272235580.9834@schroedinger.engr.sgi.com>
	 <20070827231214.99e3c33f.akpm@linux-foundation.org>
Content-Type: text/plain
Date: Tue, 28 Aug 2007 10:05:27 -0400
Message-Id: <1188309928.5079.37.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm <linux-mm@kvack.org>, mel@skynet.ie, y-goto@jp.fujitsu.com, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2007-08-27 at 23:12 -0700, Andrew Morton wrote:
> On Mon, 27 Aug 2007 22:53:15 -0700 (PDT) Christoph Lameter <clameter@sgi.com> wrote:
<something>
> 
> > On Mon, 27 Aug 2007, Andrew Morton wrote:
<something else>
<and so on, ...>

Wow!  Who'd have thought such a simple PATCH/RFC would generate such an
"animated" discussion!

Stepping back, as Andrew suggests, this all started when I added a
couple of temporary debug printk's to display the node state masks being
generated.  I noted that I wasn't seeing the N_CPU mask getting
populated.  [Turns out this was because I was printing too early--before
the other cpus came up and called process_zones().]  Christoph suggested
that a /proc variable to display the maps would be useful to some
applications/shell scripts...   

I thought I'd give it a try, but thinking that /proc variables were
discouraged, where else but sysfs to put them.  A class attribute
to /sys/devices/system/node seemed like the appropriate place.

I do recall seeing the discussion/"golden rule" about a sysfs having a
single value, but:

1) I forgot.
2) I was making a change in drivers/base/node.c where I had the meminfo
"monstrosity" as an example
3) While it makes sense for settable attributes to be separate files,
for displaying a related set of info, like meminfo and node states, it
just seems silly to duplicate code and allocate multiple sysfs objects
for what can be done with so simply with a single file.

I'm not wedded to this interface.  However, I realy don't think it's
worth doing as multiple files.

Regarding Andrew's comment about "user interface code in the kernel":
This was my reaction when I first encountered Linux's procfs with ascii
formatted files.  I was coming from a Unix background with a binary
procfs interface.  Again, it seemed silly to have "all that" formatting
and parsing code sitting around in the kernel, given how infrequently
its executed, in the grand scheme of things.  However, I must admit that
I've become addicted to the ease with which one can write one-off
scripts to query configuration/statistics, tune/modify behavior or
trigger actions via just cat'ing from and/or echo'ing to a /proc or /sys
file.

So, where to go with this patch?  Drop it?  Leave it as is?  Move
it /proc so that it can be a single file?   Make it multiple files in
sysfs?  Putting it as politely as possible, the last is not my favorite
option, but if folks think this info is useful and that's the way to go,
so be it.  And what about mask vs list?  It's a 4 character change in
the code to go either way.

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Date: Mon, 27 Aug 2007 18:14:05 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH/RFC]  Add node 'states' sysfs class attribute - V2
Message-Id: <20070827181405.57a3d8fe.akpm@linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0708271702520.1787@schroedinger.engr.sgi.com>
References: <200708242228.l7OMS5fU017948@imap1.linux-foundation.org>
	<1188248528.5952.95.camel@localhost>
	<20070827170159.0a79529d.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0708271702520.1787@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm <linux-mm@kvack.org>, mel@skynet.ie, y-goto@jp.fujitsu.com, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

On Mon, 27 Aug 2007 17:08:02 -0700 (PDT) Christoph Lameter <clameter@sgi.com> wrote:

> On Mon, 27 Aug 2007, Andrew Morton wrote:
> 
> > Perhaps including sample output would help to explain wtf this does. 
> > afaict it will spit out a bitmap like:
> > 
> > possible: 11110000
> > on-line: 11010000
> > normal memory: 01110000
> > etc
> > 
> > or something like that, dunno.  Please document this interface for us?
> 
> We also talked about having nodelist_scnprintf call bitmap_scnlistprintf. 
> I'd expect that to be a separate patch. The output should then be more 
> like
> 
> possible: 0-4
> online: 0-1, 3

really?  with commas and spaces and minus signs and colons?  ug, what next?
animated ascii art?  This is sysfs, not procfs ;)

> normal memory: 1-3
> 
> > > +	"normal memory:",
> > > +#ifdef CONFIG_HIGHMEM
> > > +	"high memory:",
> > 
> > Do we really want a space in here?  It makes parsing somewhat
> > harder.  Do the other files in /sys/devices/system/node take care to avoid
> > doing this?
> 
> This is the first file in that directory. The files in
> /sys/devices/system/node/nodeX  use _ there.
> 
> > And what happened to the one-value-per-sysfs file rule?  Did we already
> > break it so much in /sys/devices/system/node that we've just given up?
> 
> /sys/devices/system/node/nodeX/meminfo is like /proc/meminfo containing 
> multiple settings.

OK, well if the meminfo file is the only one in there which broke the
golden rule, I don't think we have sufficient excuse to break it again.

$ cat  /sys/devices/system/node/possible
0-4
$

I think a bitmap would be better, personally.

That in fact makes "possible" unneeded, doesn't it?  It would always be
all-ones?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

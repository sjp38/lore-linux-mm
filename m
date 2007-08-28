Date: Mon, 27 Aug 2007 17:08:02 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH/RFC]  Add node 'states' sysfs class attribute - V2
In-Reply-To: <20070827170159.0a79529d.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0708271702520.1787@schroedinger.engr.sgi.com>
References: <200708242228.l7OMS5fU017948@imap1.linux-foundation.org>
 <1188248528.5952.95.camel@localhost> <20070827170159.0a79529d.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm <linux-mm@kvack.org>, mel@skynet.ie, y-goto@jp.fujitsu.com, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

On Mon, 27 Aug 2007, Andrew Morton wrote:

> Perhaps including sample output would help to explain wtf this does. 
> afaict it will spit out a bitmap like:
> 
> possible: 11110000
> on-line: 11010000
> normal memory: 01110000
> etc
> 
> or something like that, dunno.  Please document this interface for us?

We also talked about having nodelist_scnprintf call bitmap_scnlistprintf. 
I'd expect that to be a separate patch. The output should then be more 
like

possible: 0-4
online: 0-1, 3
normal memory: 1-3

> > +	"normal memory:",
> > +#ifdef CONFIG_HIGHMEM
> > +	"high memory:",
> 
> Do we really want a space in here?  It makes parsing somewhat
> harder.  Do the other files in /sys/devices/system/node take care to avoid
> doing this?

This is the first file in that directory. The files in
/sys/devices/system/node/nodeX  use _ there.

> And what happened to the one-value-per-sysfs file rule?  Did we already
> break it so much in /sys/devices/system/node that we've just given up?

/sys/devices/system/node/nodeX/meminfo is like /proc/meminfo containing 
multiple settings.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

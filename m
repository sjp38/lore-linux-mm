Date: Tue, 28 Aug 2007 12:34:42 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH/RFC]  Add node 'states' sysfs class attribute - V2
In-Reply-To: <20070827231214.99e3c33f.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0708281231540.16473@schroedinger.engr.sgi.com>
References: <200708242228.l7OMS5fU017948@imap1.linux-foundation.org>
 <1188248528.5952.95.camel@localhost> <20070827170159.0a79529d.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0708271702520.1787@schroedinger.engr.sgi.com>
 <20070827181405.57a3d8fe.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0708271826180.10344@schroedinger.engr.sgi.com>
 <20070827201822.2506b888.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0708272210210.9748@schroedinger.engr.sgi.com>
 <20070827222912.8b364352.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0708272235580.9834@schroedinger.engr.sgi.com>
 <20070827231214.99e3c33f.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm <linux-mm@kvack.org>, mel@skynet.ie, y-goto@jp.fujitsu.com, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

On Mon, 27 Aug 2007, Andrew Morton wrote:

> Just step back from this for a minute, and think how utterly lame that is. 
> User interface code in the kernel because we (actually you guys) have not
> expended the tiny amount of effort and initiative which would be required
> to develop a little utility to do it.

A little utility that would cause a lot of work to keep up to date when 
the kernel can already give you the bare numbers you need? We have tools 
for sysadmins that collect these numbers and present a higher level 
overview but that does not help us. If they report a problem then you have 
to dig down into where this information come from to figure out what is 
wrong.

> > The cpu affinity is a horror to see on 4096 cpu systems. If you 
> > want to figure out to which cpu the process has restricted itself then you 
> > need to do some quick hex conversions in your mind.
> 
> wtf?  You meen nobody has written the teeny bit of code which is needed to
> convert that info into your desired format?

Of course there is somewhere. But it summarizes various things and so it 
is mostly useless baggage if you are debugging a kernel problem.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

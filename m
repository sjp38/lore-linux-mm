Subject: Re: [PATCH/RFC] Add node states sysfs class attributeS - V3
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <Pine.LNX.4.64.0708291513030.3862@schroedinger.engr.sgi.com>
References: <200708242228.l7OMS5fU017948@imap1.linux-foundation.org>
	 <20070827181405.57a3d8fe.akpm@linux-foundation.org>
	 <Pine.LNX.4.64.0708271826180.10344@schroedinger.engr.sgi.com>
	 <20070827201822.2506b888.akpm@linux-foundation.org>
	 <Pine.LNX.4.64.0708272210210.9748@schroedinger.engr.sgi.com>
	 <20070827222912.8b364352.akpm@linux-foundation.org>
	 <Pine.LNX.4.64.0708272235580.9834@schroedinger.engr.sgi.com>
	 <20070827231214.99e3c33f.akpm@linux-foundation.org>
	 <1188309928.5079.37.camel@localhost>
	 <Pine.LNX.4.64.0708281458520.17559@schroedinger.engr.sgi.com>
	 <29495f1d0708281513g406af15an8139df5fae20ad35@mail.gmail.com>
	 <1188398621.5121.13.camel@localhost>
	 <Pine.LNX.4.64.0708291039210.21184@schroedinger.engr.sgi.com>
	 <1188423105.5121.47.camel@localhost>
	 <Pine.LNX.4.64.0708291513030.3862@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Thu, 30 Aug 2007 09:34:00 -0400
Message-Id: <1188480841.5794.16.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm <linux-mm@kvack.org>, Nish Aravamudan <nish.aravamudan@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, mel@skynet.ie, y-goto@jp.fujitsu.com, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2007-08-29 at 15:14 -0700, Christoph Lameter wrote:
> On Wed, 29 Aug 2007, Lee Schermerhorn wrote:
> 
> > root@gwydyr(root):cat /sys/devices/system/node/possible
> > possible:       0-255
> 
> The file is already called "possible". Repeating it in the output will
> make it difficult to parse.

Yeah.  I noticed, after I posted, how stupid that looked.  Clear a case
of "premature patch-ulation".  I'm fixing it now.  

> 
> > +static ssize_t
> > +print_nodes_possible(struct sysdev_class *class, char *buf)
> > +{
> > +	return print_nodes_state(N_POSSIBLE, buf);
> > +}
> > +
> > +static ssize_t
> > +print_nodes_online(struct sysdev_class *class, char *buf)
> > +{
> > +	return print_nodes_state(N_ONLINE, buf);
> > +}
> > +
> > +static ssize_t
> > +print_nodes_has_normal_memory(struct sysdev_class *class, char *buf)
> > +{
> > +	return print_nodes_state(N_NORMAL_MEMORY, buf);
> > +}
> > +
> > +static ssize_t
> > +print_nodes_has_cpu(struct sysdev_class *class, char *buf)
> > +{
> > +	return print_nodes_state(N_CPU, buf);
> > +}
> 
> Is there a way to avoid having to add another one of these if we add
> a new node state?

I haven't figure out a way from the info I'm given in the show/print
routine [just the node class and the buffer address] to figure out which
attribute file was read, or I'd have avoided the function per attribute
nonsense.

> 
> Also there is a CR after the type.

Took me a minute to figure out what you meant.  Again, old habits...
I've always put my function names against the left margin for easy
searching.  But I have read where this is discouraged.

I will say that the patch passed checkpatch just fine.  I'll fix it in
the respin.

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

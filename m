Date: Mon, 27 Aug 2007 12:11:52 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH/RFC]  Add node 'states' sysfs class attribute
In-Reply-To: <1188236904.5952.72.camel@localhost>
Message-ID: <Pine.LNX.4.64.0708271203170.4667@schroedinger.engr.sgi.com>
References: <200708242228.l7OMS5fU017948@imap1.linux-foundation.org>
 <1188236904.5952.72.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: linux-mm <linux-mm@kvack.org>, mel@skynet.ie, y-goto@jp.fujitsu.com, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

On Mon, 27 Aug 2007, Lee Schermerhorn wrote:

> Works on my numa platform:  4 nodes with cpus, one memory only node.
> 
> Questions:
> 
> 1)  if this is useful, do we need/want the possible mask?

Yes that is important for software that wants to allocate per node 
structures. The possible mask shows which nodes could be activated later.

 > 2)  how about teaching nodemask_scnprintf() to suppress leading
>     words of all zeros?

Leading words of all zeroes? nodemask_scnprintf calls bitmap_scnprintf(). 
Maybe it should call bitmap_scnlistprintf() instead?


> +static ssize_t
> +print_node_states(struct class *class, char *buf)
> +{
> +	int i;
> +	int n;
> +	size_t  size = PAGE_SIZE;
> +	ssize_t len = 0;

The size varies? Isnt the len enough. Maybe just using one variable would 
simplify the code?

> +
> +	for (i=0; i < NR_NODE_STATES; ++i) {

Missing blanks around assignment. Please use i++.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

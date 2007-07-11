Subject: Re: [patch 01/12] NUMA: Generic management of nodemasks for
	various purposes
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <Pine.LNX.4.64.0707111204470.17503@schroedinger.engr.sgi.com>
References: <20070711182219.234782227@sgi.com>
	 <20070711182250.005856256@sgi.com>
	 <Pine.LNX.4.64.0707111204470.17503@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Wed, 11 Jul 2007 15:32:21 -0400
Message-Id: <1184182341.9070.11.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@linux-foundation.org, kxr@sgi.com, linux-mm@kvack.org, Nishanth Aravamudan <nacc@us.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2007-07-11 at 12:06 -0700, Christoph Lameter wrote:
> On Wed, 11 Jul 2007, Christoph Lameter wrote:
> 
> > -EXPORT_SYMBOL(node_possible_map);
> > +nodemask_t node_states[NR_NODE_STATES] __read_mostly = {
> > +	[N_POSSIBLE] => NODE_MASK_ALL,
> > +	[N_ONLINE] =>{ { [0] = 1UL } }
> > +};
> > +EXPORT_SYMBOL(node_states);
> 
> Crap here too. I desperately need a vacation. Next week....

Hi, Christoph.

I've grabbed your patch set [trying to keep track of updates ;-)].  I'll
test on various platforms here over the next couple of days and let you
know what I find.

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

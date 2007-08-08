Date: Wed, 8 Aug 2007 16:40:50 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Audit of "all uses of node_online()"
In-Reply-To: <1186611582.5055.95.camel@localhost>
Message-ID: <Pine.LNX.4.64.0708081638270.17335@schroedinger.engr.sgi.com>
References: <20070727194316.18614.36380.sendpatchset@localhost>
 <20070727194322.18614.68855.sendpatchset@localhost>
 <20070731192241.380e93a0.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0707311946530.6158@schroedinger.engr.sgi.com>
 <20070731200522.c19b3b95.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0707312006550.22443@schroedinger.engr.sgi.com>
 <20070731203203.2691ca59.akpm@linux-foundation.org>  <1185977011.5059.36.camel@localhost>
  <Pine.LNX.4.64.0708011037510.20795@schroedinger.engr.sgi.com>
 <1186085994.5040.98.camel@localhost>  <Pine.LNX.4.64.0708021323390.9711@schroedinger.engr.sgi.com>
 <1186611582.5055.95.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: ak@suse.de, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Nishanth Aravamudan <nacc@us.ibm.com>, pj@sgi.com, kxr@sgi.com, Mel Gorman <mel@skynet.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, 8 Aug 2007, Lee Schermerhorn wrote:

> First note that mpol_check_policy() is always called just before
> mpol_new() [except in the case of share policy init which is covered by
> the fix mentioned below in previous mail re: parsing mount options].
> Now, looking at this more, I think mpol_check_policy() could [should?]
> ensure that the argument nodemask is non-null after ANDing with the
> N_HIGH_MEMORY mask--i.e., contains at least one node with memory.

Hmmm... I thought about this yesterday and I thought that maybe the 
nodemask needs to allow all possible nodes? What if the nodemask is going 
to be used to select a node for a device? Or a cpu on a certain set of 
nodes? If we restrict it to the set of valid memory nodes then the policy
can only be used to select memory nodes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

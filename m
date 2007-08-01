Date: Tue, 31 Jul 2007 20:05:22 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 01/14] NUMA: Generic management of nodemasks for various
 purposes
Message-Id: <20070731200522.c19b3b95.akpm@linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0707311946530.6158@schroedinger.engr.sgi.com>
References: <20070727194316.18614.36380.sendpatchset@localhost>
	<20070727194322.18614.68855.sendpatchset@localhost>
	<20070731192241.380e93a0.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0707311946530.6158@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Lee Schermerhorn <lee.schermerhorn@hp.com>, linux-mm@kvack.org, ak@suse.de, Nishanth Aravamudan <nacc@us.ibm.com>, pj@sgi.com, kxr@sgi.com, Mel Gorman <mel@skynet.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, 31 Jul 2007 19:52:23 -0700 (PDT) Christoph Lameter <clameter@sgi.com> wrote:

> On Tue, 31 Jul 2007, Andrew Morton wrote:
> 
> > >
> > > +#define for_each_node_state(node, __state) \
> > > +	for ( (node) = 0; (node) != 0; (node) = 1)
> > 
> > That looks weird.
> 
> Yup and we have committed the usual sin of not testing !NUMA.

ooookay...   I don't think I want to be the first person who gets
to do that, so I shall duck them for -mm2.

I think there were updates pending anyway.   I saw several under-replied-to
patches from Lee but it wasn't clear it they were relevant to these changes
or what.

I'll let things cook a bit more.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

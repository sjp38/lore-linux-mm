Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l71FQsY3026310
	for <linux-mm@kvack.org>; Wed, 1 Aug 2007 11:26:54 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l71FPbwE501878
	for <linux-mm@kvack.org>; Wed, 1 Aug 2007 11:25:38 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l71FPbEW007660
	for <linux-mm@kvack.org>; Wed, 1 Aug 2007 11:25:37 -0400
Date: Wed, 1 Aug 2007 08:25:36 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [PATCH 01/14] NUMA: Generic management of nodemasks for various purposes
Message-ID: <20070801152536.GF31324@us.ibm.com>
References: <20070727194316.18614.36380.sendpatchset@localhost> <20070727194322.18614.68855.sendpatchset@localhost> <20070731192241.380e93a0.akpm@linux-foundation.org> <Pine.LNX.4.64.0707311946530.6158@schroedinger.engr.sgi.com> <20070731200522.c19b3b95.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070731200522.c19b3b95.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <clameter@sgi.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, linux-mm@kvack.org, ak@suse.de, pj@sgi.com, kxr@sgi.com, Mel Gorman <mel@skynet.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On 31.07.2007 [20:05:22 -0700], Andrew Morton wrote:
> On Tue, 31 Jul 2007 19:52:23 -0700 (PDT) Christoph Lameter <clameter@sgi.com> wrote:
> 
> > On Tue, 31 Jul 2007, Andrew Morton wrote:
> > 
> > > >
> > > > +#define for_each_node_state(node, __state) \
> > > > +	for ( (node) = 0; (node) != 0; (node) = 1)
> > > 
> > > That looks weird.
> > 
> > Yup and we have committed the usual sin of not testing !NUMA.
> 
> ooookay...   I don't think I want to be the first person who gets
> to do that, so I shall duck them for -mm2.

I'm testing these patches (since they gate my stack of hugetlb
fixes/additions) on:

x86 !NUMA, x86 NUMA, x86_64 !NUMA, x86_64 NUMA, ppc64 !NUMA, ppc64 NUMA
and ia64 NUMA.

I already reported the issue you saw, but hadn't had time to look into
it yet; and also reported the NUMAQ issue which prompted the discussion
of 32-bit NUMA removal.

I'll keep doing that testing and reporting the results.

Thanks,
Nish

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

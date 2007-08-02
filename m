Date: Thu, 2 Aug 2007 13:00:03 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 01/14] NUMA: Generic management of nodemasks for various
 purposes
In-Reply-To: <20070802162348.GA23133@skynet.ie>
Message-ID: <Pine.LNX.4.64.0708021259150.8527@schroedinger.engr.sgi.com>
References: <20070727194316.18614.36380.sendpatchset@localhost>
 <20070727194322.18614.68855.sendpatchset@localhost>
 <20070731192241.380e93a0.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0707311946530.6158@schroedinger.engr.sgi.com>
 <20070731200522.c19b3b95.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0707312006550.22443@schroedinger.engr.sgi.com>
 <20070731203203.2691ca59.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0707312151400.2894@schroedinger.engr.sgi.com>
 <20070731220727.1fd4b699.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0707312214350.2997@schroedinger.engr.sgi.com>
 <20070802162348.GA23133@skynet.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Lee Schermerhorn <lee.schermerhorn@hp.com>, linux-mm@kvack.org, ak@suse.de, Nishanth Aravamudan <nacc@us.ibm.com>, pj@sgi.com, kxr@sgi.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, 2 Aug 2007, Mel Gorman wrote:

> With the pci_create_bus() issue fixed up, I was able to boot on numaq
> with the patch from your git tree applied. It survived running kernbench,

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

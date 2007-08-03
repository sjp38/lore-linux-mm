Date: Fri, 3 Aug 2007 09:36:08 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: NUMA policy issues with ZONE_MOVABLE
In-Reply-To: <20070803093207.GA20987@skynet.ie>
Message-ID: <Pine.LNX.4.64.0708030935180.17307@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0707242120370.3829@schroedinger.engr.sgi.com>
 <20070725111646.GA9098@skynet.ie> <Pine.LNX.4.64.0707251212300.8820@schroedinger.engr.sgi.com>
 <20070802140904.GA16940@skynet.ie> <Pine.LNX.4.64.0708021152370.7719@schroedinger.engr.sgi.com>
 <20070802194211.GE23133@skynet.ie> <Pine.LNX.4.64.0708021251180.8527@schroedinger.engr.sgi.com>
 <20070803093207.GA20987@skynet.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: linux-mm@kvack.org, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, ak@suse.de, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, akpm@linux-foundation.org, pj@sgi.com
List-ID: <linux-mm.kvack.org>

(Note there may be performance issues because of the IPI that is now 
necessary on each vmstat access... This means applications polling may 
have to reduce their frequency of access to these variables.)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

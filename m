Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l5CLp5Wk030502
	for <linux-mm@kvack.org>; Tue, 12 Jun 2007 17:51:05 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5CLp3ft251486
	for <linux-mm@kvack.org>; Tue, 12 Jun 2007 15:51:04 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5CLp3YP024357
	for <linux-mm@kvack.org>; Tue, 12 Jun 2007 15:51:03 -0600
Date: Tue, 12 Jun 2007 14:51:01 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [patch 2/3] Fix GFP_THISNODE behavior for memoryless nodes
Message-ID: <20070612215101.GJ3798@us.ibm.com>
References: <20070612204843.491072749@sgi.com> <20070612205738.548677035@sgi.com> <alpine.DEB.0.99.0706121403420.5104@chino.kir.corp.google.com> <Pine.LNX.4.64.0706121406020.1850@schroedinger.engr.sgi.com> <alpine.DEB.0.99.0706121408250.5104@chino.kir.corp.google.com> <Pine.LNX.4.64.0706121422330.2322@schroedinger.engr.sgi.com> <alpine.DEB.0.99.0706121434310.8937@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.0.99.0706121434310.8937@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Christoph Lameter <clameter@sgi.com>, akpm@linux-foundation.org, linux-mm@kvack.org, ak@suse.de, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

On 12.06.2007 [14:34:40 -0700], David Rientjes wrote:
> On Tue, 12 Jun 2007, Christoph Lameter wrote:
> 
> > On Tue, 12 Jun 2007, David Rientjes wrote:
> > 
> > > That's the point.  Isn't !node_memory(nid) unlikely?
> > 
> > Correct.
> > 
> > Use unlikely
> > 
> > Signed-off-cy: Christoph Lameter <clameter@sgi.com>
> 
> Acked-by: David Rientjes <rientjes@google.com>

Yep, definitely makes sense.

Acked-by: Nishanth Aravamudan <nacc@us.ibm.com>

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

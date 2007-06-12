Date: Tue, 12 Jun 2007 14:34:40 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 2/3] Fix GFP_THISNODE behavior for memoryless nodes
In-Reply-To: <Pine.LNX.4.64.0706121422330.2322@schroedinger.engr.sgi.com>
Message-ID: <alpine.DEB.0.99.0706121434310.8937@chino.kir.corp.google.com>
References: <20070612204843.491072749@sgi.com> <20070612205738.548677035@sgi.com>
 <alpine.DEB.0.99.0706121403420.5104@chino.kir.corp.google.com>
 <Pine.LNX.4.64.0706121406020.1850@schroedinger.engr.sgi.com>
 <alpine.DEB.0.99.0706121408250.5104@chino.kir.corp.google.com>
 <Pine.LNX.4.64.0706121422330.2322@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, ak@suse.de, Nishanth Aravamudan <nacc@us.ibm.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

On Tue, 12 Jun 2007, Christoph Lameter wrote:

> On Tue, 12 Jun 2007, David Rientjes wrote:
> 
> > That's the point.  Isn't !node_memory(nid) unlikely?
> 
> Correct.
> 
> Use unlikely
> 
> Signed-off-cy: Christoph Lameter <clameter@sgi.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

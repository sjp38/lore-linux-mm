Date: Thu, 14 Jun 2007 09:13:12 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC 10/13] Memoryless nodes: Fix GFP_THISNODE behavior
In-Reply-To: <20070614160704.GE7469@us.ibm.com>
Message-ID: <Pine.LNX.4.64.0706140912540.29612@schroedinger.engr.sgi.com>
References: <20070614075026.607300756@sgi.com> <20070614075336.405903951@sgi.com>
 <20070614160704.GE7469@us.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 14 Jun 2007, Nishanth Aravamudan wrote:

> > Add a new set of zonelists for each node that only contain the nodes
> > that belong to the zones itself so that no fallback is possible.
> 
> Should be
> 
> Add a new set of zonelists for each node that only contain the zones
> that belong to the node itself so that no fallback is possible?

Right.


> This is the last patch in the stack I should based my patches on,
> correct (I believe 11-13 were mis-sends)?

Right.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Date: Tue, 12 Jun 2007 14:37:16 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 1/3] NUMA: introduce node_memory_map
In-Reply-To: <alpine.DEB.0.99.0706121430240.8937@chino.kir.corp.google.com>
Message-ID: <Pine.LNX.4.64.0706121436150.5196@schroedinger.engr.sgi.com>
References: <20070612204843.491072749@sgi.com> <20070612205738.309078596@sgi.com>
 <alpine.DEB.0.99.0706121401060.5104@chino.kir.corp.google.com>
 <Pine.LNX.4.64.0706121407070.1850@schroedinger.engr.sgi.com>
 <alpine.DEB.0.99.0706121409170.5104@chino.kir.corp.google.com>
 <Pine.LNX.4.64.0706121426020.2322@schroedinger.engr.sgi.com>
 <alpine.DEB.0.99.0706121430240.8937@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, ak@suse.de, Nishanth Aravamudan <nacc@us.ibm.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

On Tue, 12 Jun 2007, David Rientjes wrote:

> I think the problem is that online and possible are adverbs and 
> adjectives, respectively, and memory is a noun.  That's why when it 
> appears in source code, it doesn't make a lot of sense for node_memory to 
> return a boolean value.  I suspect it would return the memory, whatever 
> that is.

A sentence such as "This is a memory node" in opposition to "This is a 
memoryless nide" would put memory to use as an adjective.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

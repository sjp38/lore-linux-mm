Date: Wed, 2 May 2007 23:37:46 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] Fix hugetlb pool allocation with empty nodes
In-Reply-To: <20070503060744.GA13015@kryten>
Message-ID: <Pine.LNX.4.64.0705022333280.5237@schroedinger.engr.sgi.com>
References: <20070503022107.GA13592@kryten> <Pine.LNX.4.64.0705021959100.4259@schroedinger.engr.sgi.com>
 <20070503060744.GA13015@kryten>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Anton Blanchard <anton@samba.org>
Cc: linux-mm@kvack.org, ak@suse.de, nish.aravamudan@gmail.com, mel@csn.ul.ie, apw@shadowen.org
List-ID: <linux-mm.kvack.org>

On Thu, 3 May 2007, Anton Blanchard wrote:

> > Why would that make us unhappy?
> 
> Since SGI boxes can have lots of NUMA nodes I was worried the patch
> might negatively affect you. It sounds like thats not so much of an
> issue.

SGI Altix systems only have a single zone on each node. Thus the zone 
fallback crap does not happen. And they are symmetric.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

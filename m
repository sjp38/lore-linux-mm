Date: Fri, 11 Apr 2003 16:32:09 -0400 (EDT)
From: Rik van Riel <riel@redhat.com>
Subject: Re: [PATCH] bootmem speedup from the IA64 tree
In-Reply-To: <20030410134334.37c86863.akpm@digeo.com>
Message-ID: <Pine.LNX.4.44.0304111631100.26007-100000@chimarrao.boston.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: Benjamin LaHaise <bcrl@redhat.com>, hch@lst.de, davidm@napali.hpl.hp.com, linux-mm@kvack.org, "Martin J. Bligh" <mbligh@aracnet.com>
List-ID: <linux-mm.kvack.org>

On Thu, 10 Apr 2003, Andrew Morton wrote:

> Does the last_success cache ever need to be updated if someone frees
> some previously-allocated memory?

I've heard rumours that some IA64 trees can't boot without
this "optimisation", suggesting that they use bootmem after
freeing it.

Doesn't make the optimisation any less valid, though ...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>

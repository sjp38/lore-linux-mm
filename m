Date: Mon, 18 Apr 2005 11:12:42 -0400 (EDT)
From: Rik van Riel <riel@redhat.com>
Subject: Re: [PATCH]: VM 3/8 PG_skipped
In-Reply-To: <16994.40579.617974.423522@gargle.gargle.HOWL>
Message-ID: <Pine.LNX.4.61.0504181111390.8456@chimarrao.boston.redhat.com>
References: <16994.40579.617974.423522@gargle.gargle.HOWL>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nikita Danilov <nikita@clusterfs.com>
Cc: linux-mm@kvack.org, Andrew Morton <AKPM@Osdl.ORG>
List-ID: <linux-mm.kvack.org>

On Sun, 17 Apr 2005, Nikita Danilov wrote:

> Don't call ->writepage from VM scanner when page is met for the first time
> during scan.

> Reason behind this is that ->writepages() will perform more efficient 
> writeout than ->writepage(). Skipping of page can be conditioned on 
> zone->pressure.

Agreed, in order to write out blocks of pages at once from
the pageout code, we'll need to wait with writing until the
dirty bit has been propagated from the ptes to the pages.

-- 
"Debugging is twice as hard as writing the code in the first place.
Therefore, if you write the code as cleverly as possible, you are,
by definition, not smart enough to debug it." - Brian W. Kernighan
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

Date: Fri, 12 Nov 2004 11:10:37 -0500 (EST)
From: Rik van Riel <riel@redhat.com>
Subject: Re: [PATCH] ignore referenced pages on reclaim when OOM
In-Reply-To: <20041110142900.09552f7f.akpm@digeo.com>
Message-ID: <Pine.LNX.4.61.0411121110080.4410@chimarrao.boston.redhat.com>
References: <16783.59834.7179.464876@thebsh.namesys.com>
 <Pine.LNX.4.44.0411081655410.8589-100000@chimarrao.boston.redhat.com>
 <20041108142837.307029fc.akpm@osdl.org> <20041110184134.GC12867@logos.cnet>
 <20041110142900.09552f7f.akpm@digeo.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: Marcelo Tosatti <marcelo.tosatti@cyclades.com>, nikita@clusterfs.com, linux-mm@kvack.org, piggin@cyberone.com.au
List-ID: <linux-mm.kvack.org>

On Wed, 10 Nov 2004, Andrew Morton wrote:

> Only in a single case: where a zone is all_unreclaimable and some pages
> have recently become reclaimable but we don't know about it yet.
>
> Certainly it can happen, but it sounds really unlikely to me.

The swap token logic can make it appear like this is the case,
unless you ignore the referenced bit when you reach priority 0.

-- 
"Debugging is twice as hard as writing the code in the first place.
Therefore, if you write the code as cleverly as possible, you are,
by definition, not smart enough to debug it." - Brian W. Kernighan
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

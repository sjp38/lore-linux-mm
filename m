Date: Wed, 10 Nov 2004 14:29:00 -0800
From: Andrew Morton <akpm@digeo.com>
Subject: Re: [PATCH] ignore referenced pages on reclaim when OOM
Message-Id: <20041110142900.09552f7f.akpm@digeo.com>
In-Reply-To: <20041110184134.GC12867@logos.cnet>
References: <16783.59834.7179.464876@thebsh.namesys.com>
	<Pine.LNX.4.44.0411081655410.8589-100000@chimarrao.boston.redhat.com>
	<20041108142837.307029fc.akpm@osdl.org>
	<20041110184134.GC12867@logos.cnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: riel@redhat.com, nikita@clusterfs.com, linux-mm@kvack.org, piggin@cyberone.com.au
List-ID: <linux-mm.kvack.org>

Marcelo Tosatti <marcelo.tosatti@cyclades.com> wrote:
>
> So z->all_unreclaimable logic and "OOM detection" are conflicting goals.

Only in a single case: where a zone is all_unreclaimable and some pages
have recently become reclaimable but we don't know about it yet.

Certainly it can happen, but it sounds really unlikely to me.  So I suspect
that if you were to fix that problem by some means, it wouldn't help
anything.

But maybe I'm wrong, or maybe the all_unreclaimable logic has rotted.  Have
you tried simply disabling it?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

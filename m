Date: Tue, 10 Jun 2008 12:08:27 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 3/7] mm: speculative page references
In-Reply-To: <20080605094825.699347000@nick.local0.net>
Message-ID: <Pine.LNX.4.64.0806101205480.17798@schroedinger.engr.sgi.com>
References: <20080605094300.295184000@nick.local0.net>
 <20080605094825.699347000@nick.local0.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: npiggin@suse.de
Cc: akpm@linux-foundation.org, torvalds@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, benh@kernel.crashing.org, paulus@samba.org
List-ID: <linux-mm.kvack.org>

On Thu, 5 Jun 2008, npiggin@suse.de wrote:

> +		 * do the right thing (see comments above).
> +		 */
> +		return 0;
> +	}
> +#endif
> +	VM_BUG_ON(PageCompound(page) && (struct page *)page_private(page) != page);

This is easier written as:

== VM_BUG_ON(PageTail(page)

And its also slightly incorrect since page_private(page) is not pointing 
to the head page for PageHead(page).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

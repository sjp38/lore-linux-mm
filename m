Date: Fri, 22 Sep 2006 21:24:49 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 0/4] lockless pagecache for 2.6.18-rc7-mm1
Message-ID: <20060922192449.GA23015@wotan.suse.de>
References: <20060922172042.22370.62513.sendpatchset@linux.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20060922172042.22370.62513.sendpatchset@linux.site>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, Sep 22, 2006 at 09:22:10PM +0200, Nick Piggin wrote:
> Hi,

Arrgh, script went wrong :( Should be:

[patch 1/4] radix-tree: use indirect bit
[patch 2/4] radix-tree: gang_lookup_slot
[patch 3/4] mm: speculative get page
[patch 4/4] mm: lockless pagecache lookups

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

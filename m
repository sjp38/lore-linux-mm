Date: Tue, 10 Jun 2008 21:40:25 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 7/7] powerpc: lockless get_user_pages_fast
In-Reply-To: <20080611031822.GA8228@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0806102138380.19967@schroedinger.engr.sgi.com>
References: <20080605094300.295184000@nick.local0.net>
 <20080605094826.128415000@nick.local0.net> <Pine.LNX.4.64.0806101159110.17798@schroedinger.engr.sgi.com>
 <20080611031822.GA8228@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: akpm@linux-foundation.org, torvalds@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, benh@kernel.crashing.org, paulus@samba.org
List-ID: <linux-mm.kvack.org>

On Wed, 11 Jun 2008, Nick Piggin wrote:

> > This is reversing the modification to make get_page_unless_zero() usable 
> > with compound page heads. Will break the slab defrag patchset.
> 
> Is the slab defrag patchset in -mm? Because you ignored my comment about
> this change that assertions should not be weakened until required by the
> actual patchset. I wanted to have these assertions be as strong as
> possible for the lockless pagecache patchset.

So you are worried about accidentally using get_page_unless_zero on a 
compound page? What would be wrong about that?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Date: Wed, 11 Jun 2008 16:20:24 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 7/7] powerpc: lockless get_user_pages_fast
In-Reply-To: <20080610230622.abed7b55.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0806111619330.23868@schroedinger.engr.sgi.com>
References: <20080605094300.295184000@nick.local0.net>
 <20080605094826.128415000@nick.local0.net> <Pine.LNX.4.64.0806101159110.17798@schroedinger.engr.sgi.com>
 <20080611031822.GA8228@wotan.suse.de> <Pine.LNX.4.64.0806102138380.19967@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0806102141010.19967@schroedinger.engr.sgi.com>
 <20080611044902.GB11545@wotan.suse.de> <20080610230622.abed7b55.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nick Piggin <npiggin@suse.de>, torvalds@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, benh@kernel.crashing.org, paulus@samba.org
List-ID: <linux-mm.kvack.org>

On Tue, 10 Jun 2008, Andrew Morton wrote:

> hasn't been made.  Carrying both versions was supposed to be a
> short-term transitional thing :(

The whatever defrag patchset includes a patch to make SLAB
experimental. So one step further.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

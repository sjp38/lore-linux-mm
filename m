Date: Wed, 11 Jun 2008 06:49:02 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 7/7] powerpc: lockless get_user_pages_fast
Message-ID: <20080611044902.GB11545@wotan.suse.de>
References: <20080605094300.295184000@nick.local0.net> <20080605094826.128415000@nick.local0.net> <Pine.LNX.4.64.0806101159110.17798@schroedinger.engr.sgi.com> <20080611031822.GA8228@wotan.suse.de> <Pine.LNX.4.64.0806102138380.19967@schroedinger.engr.sgi.com> <Pine.LNX.4.64.0806102141010.19967@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0806102141010.19967@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@linux-foundation.org, torvalds@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, benh@kernel.crashing.org, paulus@samba.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 10, 2008 at 09:41:33PM -0700, Christoph Lameter wrote:
> And yes slab defrag is part of linux-next. So it would break.

Can memory management patches go though mm/? I dislike the cowboy
method of merging things that some other subsystems have adopted :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

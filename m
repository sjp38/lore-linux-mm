From: David Howells <dhowells@redhat.com>
In-Reply-To: <20050808145430.15394c3c.akpm@osdl.org> 
References: <20050808145430.15394c3c.akpm@osdl.org>  <42F57FCA.9040805@yahoo.com.au> <200508090710.00637.phillips@arcor.de> <200508090724.30962.phillips@arcor.de> 
Subject: Re: [RFC][patch 0/2] mm: remove PageReserved 
Date: Wed, 10 Aug 2005 14:13:33 +0100
Message-ID: <31567.1123679613@warthog.cambridge.redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Daniel Phillips <phillips@arcor.de>, nickpiggin@yahoo.com.au, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hugh@veritas.com, torvalds@osdl.org, andrea@suse.de, benh@kernel.crashing.org
List-ID: <linux-mm.kvack.org>

Andrew Morton <akpm@osdl.org> wrote:

> > ...kill PG_checked please :)  Or at least keep it from spreading.
> > 
> 
> It already spread - ext3 is using it and I think reiser4.  I thought I had
> a patch to rename it to PG_misc1 or somesuch, but no.  It's mandate becomes
> "filesystem-specific page flag".

You're carrying a patch to stick a flag called PG_fs_misc, but that has the
same value as PG_checked. An extra page flag beyond PG_uptodate, PG_lock and
PG_writeback is required to make readpage through the cache non-synchronous.

David
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

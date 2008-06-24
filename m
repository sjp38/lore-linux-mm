Date: Tue, 24 Jun 2008 21:19:37 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: Can get_user_pages( ,write=1, force=1, ) result in a read-only
 pte and _count=2?
In-Reply-To: <20080624151908.GO10062@sgi.com>
Message-ID: <Pine.LNX.4.64.0806242106230.21305@blonde.site>
References: <200806190329.30622.nickpiggin@yahoo.com.au>
 <Pine.LNX.4.64.0806181944080.4968@blonde.site> <200806191307.04499.nickpiggin@yahoo.com.au>
 <Pine.LNX.4.64.0806191154270.7324@blonde.site> <20080619133809.GC10123@sgi.com>
 <Pine.LNX.4.64.0806191441040.25832@blonde.site> <20080623155400.GH10123@sgi.com>
 <Pine.LNX.4.64.0806231718460.16782@blonde.site> <20080623175203.GI10123@sgi.com>
 <Pine.LNX.4.64.0806232134330.19691@blonde.site> <20080624151908.GO10062@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robin Holt <holt@sgi.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Ingo Molnar <mingo@elte.hu>, Christoph Lameter <clameter@sgi.com>, Jack Steiner <steiner@sgi.com>, Rik van Riel <riel@redhat.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 24 Jun 2008, Robin Holt wrote:
> OK.  I just gave it a try and I still get a failure with this patch
> applied.

Thanks a lot for trying.  That's disappointing, I don't understand it.
Would it be possible for you to debug what is actually happening when
this page is COWed?  It seems to me that there's something else going
on that we don't yet know about.

> I can't help wondering if we (XPMEM, IB, etc) shouldn't be setting a
> page flag indicating that the attempt to swap this page out should not
> even be tried.  I would guess this has already been discussed to death.
> If so, I am sorry, but I missed those discussions.

No, I don't think there's been any such discussion,
apart from the http://lkml.org/lkml/2006/9/14/384
threads I indicated before.  get_user_pages has always been very
much about pinning a page in memory, despite attempts to swap it out.

If you want to prevent the page from being pulled out of its pagetable,
then use mlock(2); but it shouldn't be necessary, once we have that
fix to the PageLocked case.  Unless there's something else going on.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Date: Sun, 22 Sep 2002 00:46:59 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: overcommit stuff
In-Reply-To: <3D8D0046.EF119E03@digeo.com>
Message-ID: <Pine.LNX.4.44.0209220037110.2265-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sat, 21 Sep 2002, Andrew Morton wrote:
> Alan,
> 
> running 10,000 tiobench threads I'm showing 23 gigs of
> `Commited_AS'.  Is this right?  Those pages are shared,
> and if they're not PROT_WRITEable then there's no way in
> which they can become unshared?   Seems to be excessively
> pessimistic?
> 
> Or is 2.5 not up to date?

I don't think Alan can be held responsible for errors in the
overcommit stuff rml ported to 2.5 and I then added fixes to.

I believe it is up to date in 2.5.

Committed_AS certainly errs on the pessimistic side, that's
what it's about.  How much swap do you have i.e. is 23GB
committed impossible, or just surprising to you?  Does the
number go back to what it started off from when you kill
off the tests?  How are "those pages" allocated e.g. what
mmap args?

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

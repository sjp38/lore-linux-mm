Date: Sun, 22 Sep 2002 02:45:14 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: overcommit stuff
In-Reply-To: <3D8D17B6.D4E1ECAE@digeo.com>
Message-ID: <Pine.LNX.4.44.0209220238560.2497-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sat, 21 Sep 2002, Andrew Morton wrote:
> Hugh Dickins wrote:
> > ...
> > > It seems very unlikely (impossible?) that those pages will
> > > ever become unshared.
> > 
> > I expect it's very unlikely (short of application bugs) that
> > those pages would become unshared; but they have been mapped
> > in such a way that the process is entitled to unshare them,
> > therefore they have been counted.  A good example of why
> > Linux does not impose strict commit accounting, and why
> > you may choose not to use Alan's strict accounting policy.
> 
> OK, thanks.   Just checking.
> 
> Is glibc mapping executables with PROT_WRITE?  If so,
> doesn't that rather devalue the whole overcommit thing?

No, it looks like glibc is doing the right thing (mapping the code
readonly and the data+bss readwrite).  And I was wrong to say it's
unlikely those pages would ever become unshared: the four 0.5MB
areas look like typical readwrite private anon allocations.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

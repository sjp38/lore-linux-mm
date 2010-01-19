Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7F82D6B006A
	for <linux-mm@kvack.org>; Tue, 19 Jan 2010 16:29:37 -0500 (EST)
Date: Tue, 19 Jan 2010 14:29:35 -0700
From: Alex Chiang <achiang@hp.com>
Subject: Re: SLUB ia64 linux-next crash bisected to 756dee75
Message-ID: <20100119212935.GG11010@ldl.fc.hp.com>
References: <20100113002923.GF2985@ldl.fc.hp.com> <alpine.DEB.2.00.1001151358110.6590@router.home> <1263587721.20615.255.camel@useless.americas.hpqcorp.net> <alpine.DEB.2.00.1001151730350.10558@router.home> <alpine.DEB.2.00.1001191252370.25101@router.home> <20100119200228.GE11010@ldl.fc.hp.com> <alpine.DEB.2.00.1001191427370.26683@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1001191427370.26683@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, penberg@cs.helsinki.fi, linux-ia64@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

* Christoph Lameter <cl@linux-foundation.org>:
> On Tue, 19 Jan 2010, Alex Chiang wrote:
> 
> > Well, making progress (maybe?).
> 
> Yes I think this is the fix.
> 
> > Now we're hitting a BUG_ON().
> 
> Thats a kfree of an object not allocated with a slab allocator.
> Recovery is easy in such a case: Dont free the object.

I don't get it.

static int sr_probe(struct device *dev)
{
	/* ... */

	cd = kzalloc(sizeof(*cd), GFP_KERNEL);
	if (!cd)
		goto fail;

	/* ... */

	fail_put:
		put_disk(disk);
	fail_free:
		kfree(cd);
}

The kfree() is balanced with kzalloc(). Unless the stack trace is
lying to us?

/ac

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

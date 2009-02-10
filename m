Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 30FCC6B003D
	for <linux-mm@kvack.org>; Tue, 10 Feb 2009 09:06:57 -0500 (EST)
Date: Tue, 10 Feb 2009 16:06:53 +0200 (EET)
From: Pekka J Enberg <penberg@cs.helsinki.fi>
Subject: Re: [PATCH] Export symbol ksize()
In-Reply-To: <20090210134651.GA5115@epbyminw8406h.minsk.epam.com>
Message-ID: <Pine.LNX.4.64.0902101605070.20991@melkki.cs.Helsinki.FI>
References: <1234272104-10211-1-git-send-email-kirill@shutemov.name>
 <84144f020902100535i4d626a9fj8cbb305120cf332a@mail.gmail.com>
 <20090210134651.GA5115@epbyminw8406h.minsk.epam.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Christoph Lameter <cl@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-crypto@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>, Geert.Uytterhoeven@sonycom.com
List-ID: <linux-mm.kvack.org>

On Tue, Feb 10, 2009 at 03:35:03PM +0200, Pekka Enberg wrote:
> > We unexported ksize() because it's a problematic interface and you
> > almost certainly want to use the alternatives (e.g. krealloc). I think
> > I need bit more convincing to apply this patch...
 
On Tue, 10 Feb 2009, Kirill A. Shutemov wrote:
> It just a quick fix. If anybody knows better solution, I have no
> objections.

Herbert, what do you think of this (untested) patch? Alternatively, we 
could do something like kfree_secure() but it seems overkill for this one 
call-site.

			Pekka

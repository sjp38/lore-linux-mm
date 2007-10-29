Date: Sun, 28 Oct 2007 19:53:55 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] slub: nr_slabs is an atomic_long_t
In-Reply-To: <20071029131540.13932677.sfr@canb.auug.org.au>
Message-ID: <Pine.LNX.4.64.0710281953460.28636@schroedinger.engr.sgi.com>
References: <20071029131540.13932677.sfr@canb.auug.org.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, 29 Oct 2007, Stephen Rothwell wrote:

> so shouldn't be passed to atomic_read.

That was already fixed AFAICT.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

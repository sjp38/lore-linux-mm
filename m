Date: Sun, 28 Oct 2007 23:56:10 -0500
From: Olof Johansson <olof@lixom.net>
Subject: Re: [PATCH] slub: nr_slabs is an atomic_long_t
Message-ID: <20071029045610.GA16100@lixom.net>
References: <20071029131540.13932677.sfr@canb.auug.org.au> <Pine.LNX.4.64.0710281953460.28636@schroedinger.engr.sgi.com> <20071029142430.fd711666.sfr@canb.auug.org.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20071029142430.fd711666.sfr@canb.auug.org.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, Oct 29, 2007 at 02:24:30PM +1100, Stephen Rothwell wrote:
> On Sun, 28 Oct 2007 19:53:55 -0700 (PDT) Christoph Lameter <clameter@sgi.com> wrote:
> >
> > That was already fixed AFAICT.
> 
> Not in Linus' tree, yet.

Nope, it's still sitting in -mm. Al Viro just posted the same fix too.


-Olof

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

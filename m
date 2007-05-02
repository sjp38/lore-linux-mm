Date: Wed, 2 May 2007 12:11:05 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: 2.6.22 -mm merge plans: slub
Message-Id: <20070502121105.de3433d5.akpm@linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0705021002040.32271@schroedinger.engr.sgi.com>
References: <20070430162007.ad46e153.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0705011846590.10660@blonde.wat.veritas.com>
	<20070501125559.9ab42896.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0705012101410.26170@blonde.wat.veritas.com>
	<20070501133618.93793687.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0705021346170.16517@blonde.wat.veritas.com>
	<Pine.LNX.4.64.0705021002040.32271@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Hugh Dickins <hugh@veritas.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2 May 2007 10:03:50 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:

> On Wed, 2 May 2007, Hugh Dickins wrote:
> 
> > But if Linus' tree is to be better than a warehouse to avoid
> > awkward merges, I still think we want it to default to on for
> > all the architectures, and for most if not all -rcs.
> 
> At some point I dream that SLUB could become the default but I thought 
> this would take at least 6 month or so. If want to force this now then I 
> will certainly have some busy weeks ahead.

s/dream/promise/ ;)

Six months sounds reasonable - I was kind of hoping for less.  Make it
default-to-on in 2.6.23-rc1, see how it goes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

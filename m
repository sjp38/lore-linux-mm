Date: Mon, 24 Jan 2005 12:33:47 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Extend clear_page by an order parameter
In-Reply-To: <20050124122350.1142ee81.davem@davemloft.net>
Message-ID: <Pine.LNX.4.58.0501241232330.17210@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.58.0501041512450.1536@schroedinger.engr.sgi.com>
 <Pine.LNX.4.44.0501082103120.5207-100000@localhost.localdomain>
 <20050108135636.6796419a.davem@davemloft.net>
 <Pine.LNX.4.58.0501211210220.25925@schroedinger.engr.sgi.com>
 <20050122234517.376ef3f8.akpm@osdl.org> <Pine.LNX.4.58.0501240835041.15963@schroedinger.engr.sgi.com>
 <20050124122350.1142ee81.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "David S. Miller" <davem@davemloft.net>
Cc: akpm@osdl.org, hugh@veritas.com, linux-ia64@vger.kernel.org, torvalds@osdl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 24 Jan 2005, David S. Miller wrote:

> On Mon, 24 Jan 2005 08:37:15 -0800 (PST)
> Christoph Lameter <clameter@sgi.com> wrote:
>
> > Then it may also be better to pass the page struct to clear_pages
> > instead of a memory address.
>
> What is more generally available at the call sites at this time?
> Consider both HIGHMEM and non-HIGHMEM setups in your estimation
> please :-)

The only call site is prep_zero_page which has a GFP flag, the order and
the pointer to struct page.

The patch makes the huge page code call prep_zero_page and scrubd will
also call prep_zero_page.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

Date: Wed, 8 Dec 2004 09:57:09 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: RE: Anticipatory prefaulting in the page fault handler V1
In-Reply-To: <B8E391BBE9FE384DAA4C5C003888BE6F02844270@scsmsx401.amr.corp.intel.com>
Message-ID: <Pine.LNX.4.58.0412080956200.27324@schroedinger.engr.sgi.com>
References: <B8E391BBE9FE384DAA4C5C003888BE6F02844270@scsmsx401.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>
Cc: nickpiggin@yahoo.com.au, Jeff Garzik <jgarzik@pobox.com>, torvalds@osdl.org, hugh@veritas.com, benh@kernel.crashing.org, linux-mm@kvack.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 8 Dec 2004, Luck, Tony wrote:

> >If a fault occurred for page x and is then followed by page
> >x+1 then it may be reasonable to expect another page fault
> >at x+2 in the future.
>
> What if the application had used "madvise(start, len, MADV_RANDOM)"
> to tell the kernel that this isn't "reasonable"?

We could use that as a way to switch of the preallocation. How expensive
is that check?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

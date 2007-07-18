Date: Wed, 18 Jul 2007 11:54:59 +0100
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH] vmalloc_32 should use GFP_KERNEL
Message-ID: <20070718115459.0cfe8ebc@the-village.bc.nu>
In-Reply-To: <1184741354.25235.222.camel@localhost.localdomain>
References: <1184739934.25235.220.camel@localhost.localdomain>
	<20070717233358.2edeaac0.akpm@linux-foundation.org>
	<1184741354.25235.222.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel list <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Dave Airlie <airlied@gmail.com>, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

On Wed, 18 Jul 2007 16:49:14 +1000
Benjamin Herrenschmidt <benh@kernel.crashing.org> wrote:

> On Tue, 2007-07-17 at 23:33 -0700, Andrew Morton wrote:
> > whoops, yes.
> > 
> > Are those errors serious and common enough for 2.6.22.x?  
> 
> No idea, so far, the nouveau DRM isn't something I would recommend to
> people to use in stable environments but heh... I don't know who else
> uses vmalloc_32.

Mostly older video capture.

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

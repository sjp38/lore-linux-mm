Date: Mon, 9 May 2005 23:30:28 +0200
From: Arjan van de Ven <arjanv@redhat.com>
Subject: Re: Fw: [Bug 4520] New: /proc/*/maps fragments too quickly compared to
Message-ID: <20050509213027.GA3963@devserv.devel.redhat.com>
References: <17023.26119.111329.865429@gargle.gargle.HOWL> <20050509142651.1d3ae91e.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20050509142651.1d3ae91e.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Wolfgang Wander <wwc@rentec.com>, mingo@elte.hu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 09, 2005 at 02:26:51PM -0700, Andrew Morton wrote:

> Possibly for the 2.6.12 release the safest approach would be to just
> disable the free area cache while we think about it.

the free area cache either is historically tricky to be fair; it has the
thankless job of either keeping at the "ealiest" small hole (and thus being
useless if most allocs are bigger than that hole) or leaving an occasionally
small hole alone and thus fragmenting memory more, like you've shown.
I like neither to be honest; the price however is a higher lookup cost (well
mitigated if vma merging is really effective) 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

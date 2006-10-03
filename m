Date: Tue, 3 Oct 2006 16:05:47 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] page_alloc: fix kernel-doc and func. declaration
In-Reply-To: <20061003154949.7953c6f9.rdunlap@xenotime.net>
Message-ID: <Pine.LNX.4.64.0610031605300.23654@schroedinger.engr.sgi.com>
References: <20061003141445.0c502d45.rdunlap@xenotime.net>
 <Pine.LNX.4.64.0610031435590.22775@schroedinger.engr.sgi.com>
 <20061003154949.7953c6f9.rdunlap@xenotime.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Randy Dunlap <rdunlap@xenotime.net>
Cc: linux-mm@kvack.org, akpm <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

On Tue, 3 Oct 2006, Randy Dunlap wrote:

> > Hmmm. With the optional ZONE_DMA patch this becomes a reservation in the 
> > first zone, which may be ZONE_NORMAL.
> 
> I didn't change any of that wording.  Do you want to change it?
> do you want me to make that change?  or what?

Just say it reserves from the first zone.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

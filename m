Date: Wed, 26 Nov 2003 11:07:18 -0800
From: Mike Fedyk <mfedyk@matchmail.com>
Subject: Re: 2.6.0-test10-mm1
Message-ID: <20031126190718.GB1566@mis-mike-wstn.matchmail.com>
References: <20031125211518.6f656d73.akpm@osdl.org> <20031126085123.A1952@infradead.org> <20031126044251.3b8309c1.akpm@osdl.org> <20031126130936.A5275@infradead.org> <20031126052900.17542bb3.akpm@osdl.org> <20031126132505.C5477@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20031126132505.C5477@infradead.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Nov 26, 2003 at 01:25:05PM +0000, Christoph Hellwig wrote:
> On Wed, Nov 26, 2003 at 05:29:00AM -0800, Andrew Morton wrote:
> > But I do not think that making a single kernel symbol inaccessible is an
> > appropriate way of resolving a GPFS licensing dispute.
> 
> well, GFPS is a derived work with or without it.  It's just that I remember
> we had that agreement about merging it only with the _GPL export.  In fact
> I'm pretty sure Paul told something about GPLed distributed filesystems from
> IBM in that context..

Are you trying to say that something that was ported from AIX is a derived
work because it has to read kernel internals to get its job done?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 884C16B005D
	for <linux-mm@kvack.org>; Tue, 21 Aug 2012 19:42:45 -0400 (EDT)
From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH v7 2/4] virtio_balloon: introduce migration primitives to balloon pages
In-Reply-To: <20120815112851.GA2707@redhat.com>
References: <f19b63dfa026fe2f8f11ec017771161775744781.1344619987.git.aquini@redhat.com> <20120813084123.GF14081@redhat.com> <20120814182244.GB13338@t510.redhat.com> <20120814195139.GA28870@redhat.com> <20120814201113.GE22133@t510.redhat.com> <20120815090528.GH4052@csn.ul.ie> <20120815092528.GA29214@redhat.com> <20120815094839.GJ4052@csn.ul.ie> <20120815100108.GA1999@redhat.com> <20120815111651.GL4052@csn.ul.ie> <20120815112851.GA2707@redhat.com>
Date: Tue, 21 Aug 2012 15:01:37 +0930
Message-ID: <87mx1o3j5y.fsf@rustcorp.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>, Mel Gorman <mel@csn.ul.ie>
Cc: Rafael Aquini <aquini@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Minchan Kim <minchan@kernel.org>

On Wed, 15 Aug 2012 14:28:51 +0300, "Michael S. Tsirkin" <mst@redhat.com> wrote:
> On Wed, Aug 15, 2012 at 12:16:51PM +0100, Mel Gorman wrote:
> > I was thinking of exactly that page->mapping == balloon_mapping check. As I
> > do not know how many active balloon drivers there might be I cannot guess
> > in advance how much of a scalability problem it will be.
> 
> Not at all sure multiple drivers are worth supporting, but multiple
> *devices* is I think worth supporting, if for no other reason than that
> they can work today. For that, we need a device pointer which Rafael
> wants to put into the mapping, this means multiple balloon mappings.

Rafael, please make sure that the balloon driver fails on the second and
subsequent balloon devices.

Michael, we only allow multiple balloon devices because it fell out of
the implementation.  If it causes us even the slightest issue, we should
not support it.  It's not a sensible setup.

Cheers,
Rusty.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

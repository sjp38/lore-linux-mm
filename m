Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 8E8816B0044
	for <linux-mm@kvack.org>; Fri,  3 Aug 2012 07:13:52 -0400 (EDT)
Date: Fri, 3 Aug 2012 08:13:09 -0300
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [PATCH v4 1/3] mm: introduce compaction and migration for virtio
 ballooned pages
Message-ID: <20120803111309.GA1848@t510.redhat.com>
References: <cover.1342485774.git.aquini@redhat.com>
 <49f828a9331c9b729fcf77226006921ec5bc52fa.1342485774.git.aquini@redhat.com>
 <20120718054824.GA32341@bbox>
 <20120720194858.GA16249@t510.redhat.com>
 <20120723023332.GA6832@bbox>
 <20120723181952.GA27373@t510.redhat.com>
 <5019975B.6010708@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5019975B.6010708@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>, "Michael S. Tsirkin" <mst@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Rafael Aquini <aquini@linux.com>

On Wed, Aug 01, 2012 at 04:53:47PM -0400, Rik van Riel wrote:
> On 07/23/2012 02:19 PM, Rafael Aquini wrote:
> 
> >In a glance, I believe this whole dance you're suggesting might just be too much
> >of an overcomplication, and the best approach would be simply teaching the
> >hotplug bits about the ballooned corner case just like it's being done to
> >compaction/migration. However, I'll look at it carefully before making any other
> >adjustments/propositions over here.
> 
> Compaction and hotplug do essentially the same thing
> here: "collect all the movable pages from a page block,
> and move them elsewhere".
> 
> Whether or not it is easier for them to share code, or
> to duplicate a few lines of code, is something that can
> be looked into later.

I'm 100% in agreement with your thoughts here.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

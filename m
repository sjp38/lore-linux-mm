Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 72B806B005D
	for <linux-mm@kvack.org>; Tue, 14 Aug 2012 16:03:39 -0400 (EDT)
Date: Tue, 14 Aug 2012 17:03:27 -0300
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [PATCH v7 1/4] mm: introduce compaction and migration for virtio
 ballooned pages
Message-ID: <20120814200326.GC22133@t510.redhat.com>
References: <cover.1344619987.git.aquini@redhat.com>
 <292b1b52e863a05b299f94bda69a61371011ac19.1344619987.git.aquini@redhat.com>
 <20120813082619.GE14081@redhat.com>
 <20120814174404.GA13338@t510.redhat.com>
 <20120814193525.GB28840@redhat.com>
 <20120814194837.GA28863@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120814194837.GA28863@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Minchan Kim <minchan@kernel.org>

On Tue, Aug 14, 2012 at 10:48:37PM +0300, Michael S. Tsirkin wrote:
> > 
> > E.g. kvm can emulate hyperv so it could in theory have hyperv balloon.
> > This is mm stuff it is best not to tie it to specific drivers.
> 
> But of course I agree this is not top priority, no need
> to block submission on this, just nice to have.
>
This surely is interesting to look at, in the near future. 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

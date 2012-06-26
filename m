Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id D130F6B004D
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 12:53:00 -0400 (EDT)
Date: Tue, 26 Jun 2012 18:52:58 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 1/4] mm: introduce compaction and migration for virtio ballooned pages
Message-ID: <20120626165258.GY11413@one.firstfloor.org>
References: <cover.1340665087.git.aquini@redhat.com> <7f83427b3894af7969c67acc0f27ab5aa68b4279.1340665087.git.aquini@redhat.com> <20120626101729.GF8103@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120626101729.GF8103@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Rafael Aquini <aquini@redhat.com>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, "Michael S. Tsirkin" <mst@redhat.com>, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org

> 
> What shocked me actually is that VM_BUG_ON code is executed on
> !CONFIG_DEBUG_VM builds and has been since 2.6.36 due to commit [4e60c86bd:
> gcc-4.6: mm: fix unused but set warnings]. I thought the whole point of
> VM_BUG_ON was to avoid expensive and usually unnecessary checks. Andi,
> was this deliberate?

The idea was that the compiler optimizes it away anyways.

I'm not fully sure what putback_balloon_page does, but if it just tests
a bit (without non variable test_bit) it should be ok.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

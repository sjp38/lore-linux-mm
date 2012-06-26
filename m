Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 397EE6B004D
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 12:54:34 -0400 (EDT)
Date: Tue, 26 Jun 2012 18:54:32 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 1/4] mm: introduce compaction and migration for virtio ballooned pages
Message-ID: <20120626165432.GZ11413@one.firstfloor.org>
References: <cover.1340665087.git.aquini@redhat.com> <7f83427b3894af7969c67acc0f27ab5aa68b4279.1340665087.git.aquini@redhat.com> <20120626101729.GF8103@csn.ul.ie> <20120626165258.GY11413@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120626165258.GY11413@one.firstfloor.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Mel Gorman <mel@csn.ul.ie>, Rafael Aquini <aquini@redhat.com>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, "Michael S. Tsirkin" <mst@redhat.com>, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org

> I'm not fully sure what putback_balloon_page does, but if it just tests
> a bit (without non variable test_bit) it should be ok.
         ^^^^^^^^^^^^^

should be "without variable ..."

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

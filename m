Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 4A7756B004D
	for <linux-mm@kvack.org>; Sat,  1 Aug 2009 11:46:38 -0400 (EDT)
Date: Sat, 1 Aug 2009 11:51:12 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 1/2] Dirty Page Tracking & on-the-fly memory mirroring
Message-ID: <20090801155112.GA10888@infradead.org>
References: <4A7390F6.6080207@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4A7390F6.6080207@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Jim Paradis <jparadis@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


Where is the actual consumer of this?  You add a lot of infrastructure
but no actualy code using it.  Working ar Red Hat should should more
than know that we don't add hooks for out of tree junk.  Or maybe you
should get a free bootcamp ticket from your manager..

Also your patch is extremly whitespace damaged, again quite sad for
someone working at a Linux company.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

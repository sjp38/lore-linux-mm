Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id D78386B003D
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 08:03:29 -0400 (EDT)
Date: Mon, 16 Mar 2009 08:02:24 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] Point the UNEVICTABLE_LRU config option at the
	documentation
Message-ID: <20090316120224.GA16506@infradead.org>
References: <20090316105945.18131.82359.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090316105945.18131.82359.stgit@warthog.procyon.org.uk>
Sender: owner-linux-mm@kvack.org
To: David Howells <dhowells@redhat.com>
Cc: lee.schermerhorn@hp.com, kosaki.motohiro@jp.fujitsu.com, minchan.kim@gmail.com, akpm@linux-foundation.org, torvalds@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 16, 2009 at 10:59:45AM +0000, David Howells wrote:
> Point the UNEVICTABLE_LRU config option at the documentation describing the
> option.

Didn't we decide a while ago that the option is pointless and the code
should always be enabled?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

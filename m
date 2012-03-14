Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 679A66B004A
	for <linux-mm@kvack.org>; Wed, 14 Mar 2012 03:51:11 -0400 (EDT)
Date: Wed, 14 Mar 2012 03:51:09 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 0/4] radix-tree: iterating general cleanup
Message-ID: <20120314075109.GA32717@infradead.org>
References: <20120207074905.29797.60353.stgit@zurg>
 <20120314073629.GA17016@infradead.org>
 <4F604D81.1060607@openvz.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4F604D81.1060607@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Christoph Hellwig <hch@infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Wed, Mar 14, 2012 at 11:49:21AM +0400, Konstantin Khlebnikov wrote:
> Christoph Hellwig wrote:
> >Any updates on this series?
> 
> I had sent "[PATCH v2 0/3] radix-tree: general iterator" February 10, there is no more updates after that.
> I just checked v2 on top "next-20120314" -- looks like all ok.

this was more a question to the MM maintainers if this is getting
merged or if there were any further comments.

We'd really like to have this interface to simplify some code in XFS.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

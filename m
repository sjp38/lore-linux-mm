Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id 7A6C26B0044
	for <linux-mm@kvack.org>; Wed, 21 Mar 2012 13:56:53 -0400 (EDT)
Date: Wed, 21 Mar 2012 12:56:50 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Patch workqueue: create new slab cache instead of hacking
In-Reply-To: <20120321160910.GB4246@google.com>
Message-ID: <alpine.DEB.2.00.1203211255290.21932@router.home>
References: <1332238884-6237-1-git-send-email-laijs@cn.fujitsu.com> <1332238884-6237-7-git-send-email-laijs@cn.fujitsu.com> <20120320154619.GA5684@google.com> <4F6944D9.5090002@cn.fujitsu.com> <CAOS58YPydFUap4HjuRATxza6VZgyrXmQHVxR83G7GRJL50ZTRQ@mail.gmail.com>
 <alpine.DEB.2.00.1203210910450.20482@router.home> <20120321160910.GB4246@google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Lai Jiangshan <laijs@cn.fujitsu.com>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 21 Mar 2012, Tejun Heo wrote:

> I don't know.  At this point, this is only for singlethread and
> unbound workqueues and we don't have too many of them left at this
> point.  I'd like to avoid creating a slab cache for this.  How about
> just leaving it be?  If we develop other use cases for larger
> alignments, let's worry about implementing something common then.

We could write a function that identifies a compatible kmalloc cache
or creates a new one if necessary. That would cut down overhead similar to
what slub merge is doing but allows more control by the developer.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

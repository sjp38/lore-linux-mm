Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id C29E16B0044
	for <linux-mm@kvack.org>; Wed,  7 Nov 2012 19:34:23 -0500 (EST)
Date: Wed, 7 Nov 2012 22:34:04 -0200
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [PATCH v11 5/7] virtio_balloon: introduce migration primitives
 to balloon pages
Message-ID: <20121108003403.GE10444@optiplex.redhat.com>
References: <cover.1352256081.git.aquini@redhat.com>
 <265aaff9a79f503672f0cdcdff204114b5b5ba5b.1352256088.git.aquini@redhat.com>
 <87625h3tl1.fsf@rustcorp.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87625h3tl1.fsf@rustcorp.com.au>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rusty Russell <rusty@rustcorp.com.au>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, "Michael S. Tsirkin" <mst@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Minchan Kim <minchan@kernel.org>, Peter Zijlstra <peterz@infradead.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On Thu, Nov 08, 2012 at 09:32:18AM +1030, Rusty Russell wrote:
> The first one can be delayed, the second one can be delayed if the host
> didn't ask for VIRTIO_BALLOON_F_MUST_TELL_HOST (qemu doesn't).
> 
> We could implement a proper request queue for these, and return -EAGAIN
> if the queue fills.  Though in practice, it's not important (it might
> help performance).

I liked the idea. Give me the directions to accomplish it and I'll give it a try
for sure.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

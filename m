Subject: Re: [vm] writing to UDF DVD+RW (/dev/sr0) while under memory
	pressure: box ==> doorstop
From: Mike Galbraith <efault@gmx.de>
In-Reply-To: <20080109150139.311f68d3.akpm@linux-foundation.org>
References: <1199447212.4529.13.camel@homer.simson.net>
	 <1199612533.4384.54.camel@homer.simson.net>
	 <1199642470.3927.12.camel@homer.simson.net>
	 <20080106122954.d8f04c98.akpm@linux-foundation.org>
	 <1199790316.4094.57.camel@homer.simson.net>
	 <20080108033801.40d0043a.akpm@linux-foundation.org>
	 <1199805713.3571.12.camel@homer.simson.net>
	 <1199806071.4174.2.camel@homer.simson.net>
	 <1199877080.4340.19.camel@homer.simson.net>
	 <20080109150139.311f68d3.akpm@linux-foundation.org>
Content-Type: text/plain
Date: Thu, 10 Jan 2008 05:21:25 +0100
Message-Id: <1199938885.4324.80.camel@homer.simson.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, bfennema@falcon.csc.calpoly.edu
List-ID: <linux-mm.kvack.org>

On Wed, 2008-01-09 at 15:01 -0800, Andrew Morton wrote:

> So are you saying that the fs throughput is unaltered by this change,
> but that the side-effects which your workload has on the overall
> machine are lessened?

Yes.  UDF IO is still a slow trickle, but the box is now fine under VM
stress, vs all allocating tasks eventually getting nailed (essentially
forever) by iprune_mutex previously.

	-Mike

P.S.  I would submit one-liner for VFS part, but it's useless without
UDF part, and nobody is hitting what I ran into while testing alleged
scsi_done regression thingy anyway.  cc added.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e35.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j6QNQShn227620
	for <linux-mm@kvack.org>; Tue, 26 Jul 2005 19:26:28 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j6QNQS9v434182
	for <linux-mm@kvack.org>; Tue, 26 Jul 2005 17:26:28 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j6QNQSnl008064
	for <linux-mm@kvack.org>; Tue, 26 Jul 2005 17:26:28 -0600
Subject: Re: Memory pressure handling with iSCSI
From: Badari Pulavarty <pbadari@us.ibm.com>
In-Reply-To: <20050726160728.55245dae.akpm@osdl.org>
References: <1122399331.6433.29.camel@dyn9047017102.beaverton.ibm.com>
	 <20050726111110.6b9db241.akpm@osdl.org>
	 <1122403152.6433.39.camel@dyn9047017102.beaverton.ibm.com>
	 <20050726114824.136d3dad.akpm@osdl.org>
	 <20050726121250.0ba7d744.akpm@osdl.org>
	 <1122412301.6433.54.camel@dyn9047017102.beaverton.ibm.com>
	 <20050726142410.4ff2e56a.akpm@osdl.org>
	 <1122414300.6433.57.camel@dyn9047017102.beaverton.ibm.com>
	 <20050726151003.6aa3aecb.akpm@osdl.org>
	 <1122418089.6433.62.camel@dyn9047017102.beaverton.ibm.com>
	 <20050726160728.55245dae.akpm@osdl.org>
Content-Type: text/plain
Date: Tue, 26 Jul 2005 16:26:16 -0700
Message-Id: <1122420376.6433.68.camel@dyn9047017102.beaverton.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2005-07-26 at 16:07 -0700, Andrew Morton wrote:
> Badari Pulavarty <pbadari@us.ibm.com> wrote:
> >
> > Here is the data with 5 ext2 filesystems. I also collected /proc/meminfo
> > every 5 seconds. As you can see, we seem to dirty 6GB of data in 20
> > seconds of starting the test. I am not sure if its bad, since we have
> > lots of free memory..
> 
> It's bad.  The logic in balance_dirty_pages() should block those write()
> callers as soon as we hit 40% dirty memory or whatever is in
> /proc/sys/vm/dirty_ratio.  So something is horridly busted.
> 
> Can you try reducing the number of filesystems even further?

Single ext2 filesystem. We still dirty pretty quickly (data collected
every 5 seconds).

 # grep Dirty OUT
Dirty:             312 kB
Dirty:         1121852 kB
Dirty:         2896952 kB
Dirty:         4344564 kB
Dirty:         5310856 kB
Dirty:         5507812 kB
Dirty:         5714884 kB
Dirty:         5865132 kB
Dirty:         6004276 kB
Dirty:         6206544 kB
Dirty:         6380524 kB
Dirty:         6583200 kB
Dirty:         6727296 kB
Dirty:         6708564 kB
Dirty:         6733768 kB
Dirty:         6737868 kB

Thanks,
Badari

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

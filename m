Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id D63D76B007E
	for <linux-mm@kvack.org>; Tue, 26 May 2009 23:26:17 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n4R3QeJK009261
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 27 May 2009 12:26:40 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4CD9745DE5D
	for <linux-mm@kvack.org>; Wed, 27 May 2009 12:26:40 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2447745DE55
	for <linux-mm@kvack.org>; Wed, 27 May 2009 12:26:40 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id EDE20E38005
	for <linux-mm@kvack.org>; Wed, 27 May 2009 12:26:39 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9F0741DB8040
	for <linux-mm@kvack.org>; Wed, 27 May 2009 12:26:39 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] readahead:add blk_run_backing_dev
In-Reply-To: <6.0.0.20.2.20090527120248.076abe38@172.19.0.2>
References: <20090527025721.GA11153@localhost> <6.0.0.20.2.20090527120248.076abe38@172.19.0.2>
Message-Id: <20090527122540.6897.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 27 May 2009 12:26:38 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Hisashi Hifumi <hifumi.hisashi@oss.ntt.co.jp>
Cc: kosaki.motohiro@jp.fujitsu.com, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "jens.axboe@oracle.com" <jens.axboe@oracle.com>
List-ID: <linux-mm.kvack.org>

> >> >The numbers look too small for a 7 disk RAID:
> >> >
> >> >        > #dd if=testdir/testfile of=/dev/null bs=16384
> >> >        >
> >> >        > -2.6.30-rc6
> >> >        > 1048576+0 records in
> >> >        > 1048576+0 records out
> >> >        > 17179869184 bytes (17 GB) copied, 224.182 seconds, 76.6 MB/s
> >> >        >
> >> >        > -2.6.30-rc6-patched
> >> >        > 1048576+0 records in
> >> >        > 1048576+0 records out
> >> >        > 17179869184 bytes (17 GB) copied, 206.465 seconds, 83.2 MB/s
> >> >
> >> >I'd suggest you to configure the array properly before coming back to
> >> >measuring the impact of this patch.
> >> 
> >> 
> >> I created 16GB file to this disk array, and mounted to testdir, dd to 
> >this directory.
> >
> >I mean, you should get >300MB/s throughput with 7 disks, and you
> >should seek ways to achieve that before testing out this patch :-)
> 
> Throughput number of storage array is very from one product to another.
> On my hardware environment I think this number is valid and
> my patch is effective.

Hifumi-san, if you really want to merge, you should reproduce this
issue on typical hardware, I think.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

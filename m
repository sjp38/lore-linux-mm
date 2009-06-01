Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 0533F6B0082
	for <linux-mm@kvack.org>; Sun, 31 May 2009 23:06:41 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n5136jgF020676
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 1 Jun 2009 12:06:45 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 909BD45DE70
	for <linux-mm@kvack.org>; Mon,  1 Jun 2009 12:06:45 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6CE1445DE6E
	for <linux-mm@kvack.org>; Mon,  1 Jun 2009 12:06:45 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4FDE11DB8043
	for <linux-mm@kvack.org>; Mon,  1 Jun 2009 12:06:45 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0B6131DB803B
	for <linux-mm@kvack.org>; Mon,  1 Jun 2009 12:06:45 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] readahead:add blk_run_backing_dev
In-Reply-To: <20090601030249.GA10348@localhost>
References: <6.0.0.20.2.20090601115104.0739dac0@172.19.0.2> <20090601030249.GA10348@localhost>
Message-Id: <20090601120524.4F5A.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon,  1 Jun 2009 12:06:44 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Hisashi Hifumi <hifumi.hisashi@oss.ntt.co.jp>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "jens.axboe@oracle.com" <jens.axboe@oracle.com>
List-ID: <linux-mm.kvack.org>

> > >> >I mean, you should get >300MB/s throughput with 7 disks, and you
> > >> >should seek ways to achieve that before testing out this patch :-)
> > >> 
> > >> Throughput number of storage array is very from one product to another.
> > >> On my hardware environment I think this number is valid and
> > >> my patch is effective.
> > >
> > >What's your readahead size? Is it large enough to cover the stripe width?
> > 
> > Do you mean strage's readahead size?
> 
> What's strage? I mean if your RAID's block device file is /dev/sda, then

I guess it's typo :-)
but I recommend he use sane test environment...


> 
>         blockdev --getra /dev/sda
> 
> will tell its readahead size in unit of 512 bytes.
> 
> Thanks,
> Fengguang
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

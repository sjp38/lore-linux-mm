Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 7ECC26B02A7
	for <linux-mm@kvack.org>; Thu,  5 Aug 2010 20:09:51 -0400 (EDT)
Received: from hpaq13.eem.corp.google.com (hpaq13.eem.corp.google.com [172.25.149.13])
	by smtp-out.google.com with ESMTP id o760Bvh0024671
	for <linux-mm@kvack.org>; Thu, 5 Aug 2010 17:11:58 -0700
Received: from gyg8 (gyg8.prod.google.com [10.243.50.136])
	by hpaq13.eem.corp.google.com with ESMTP id o760Bu3q015805
	for <linux-mm@kvack.org>; Thu, 5 Aug 2010 17:11:56 -0700
Received: by gyg8 with SMTP id 8so3370804gyg.17
        for <linux-mm@kvack.org>; Thu, 05 Aug 2010 17:11:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100806084928.31DE.A69D9226@jp.fujitsu.com>
References: <20100805132433.d1d7927b.akpm@linux-foundation.org>
	<AANLkTik9AMf1pmsguB843UC9Qq6KxBcWiN_qyeiDPp1O@mail.gmail.com>
	<20100806084928.31DE.A69D9226@jp.fujitsu.com>
From: Michael Rubin <mrubin@google.com>
Date: Thu, 5 Aug 2010 17:11:35 -0700
Message-ID: <AANLkTimD4jkkPpnhQhR+OF=6=dWV2dJj4M_DGfAmHgRQ@mail.gmail.com>
Subject: Re: [PATCH 2/2] writeback: Adding pages_dirtied and
	pages_entered_writeback
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, jack@suse.cz, david@fromorbit.com, hch@lst.de, axboe@kernel.dk
List-ID: <linux-mm.kvack.org>

On Thu, Aug 5, 2010 at 4:56 PM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
> /proc/vmstat already have both.
>
> cat /proc/vmstat |grep nr_dirty
> cat /proc/vmstat |grep nr_writeback
>
> Also, /sys/devices/system/node/node0/meminfo show per-node stat.
>
> Perhaps, I'm missing your point.

These only show the number of dirty pages present in the system at the
point they are queried.
The counter I am trying to add are increasing over time. They allow
developers to see rates of pages being dirtied and entering writeback.
Which is very helpful.

mrubin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

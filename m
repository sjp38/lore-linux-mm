Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 52FE96B0364
	for <linux-mm@kvack.org>; Fri, 20 Aug 2010 19:52:04 -0400 (EDT)
Received: from wpaz29.hot.corp.google.com (wpaz29.hot.corp.google.com [172.24.198.93])
	by smtp-out.google.com with ESMTP id o7KNq0Ni021677
	for <linux-mm@kvack.org>; Fri, 20 Aug 2010 16:52:00 -0700
Received: from ywi6 (ywi6.prod.google.com [10.192.9.6])
	by wpaz29.hot.corp.google.com with ESMTP id o7KNpxqa026675
	for <linux-mm@kvack.org>; Fri, 20 Aug 2010 16:51:59 -0700
Received: by ywi6 with SMTP id 6so1628566ywi.22
        for <linux-mm@kvack.org>; Fri, 20 Aug 2010 16:51:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100820100855.GC8440@localhost>
References: <1282296689-25618-1-git-send-email-mrubin@google.com>
 <1282296689-25618-4-git-send-email-mrubin@google.com> <20100820100855.GC8440@localhost>
From: Michael Rubin <mrubin@google.com>
Date: Fri, 20 Aug 2010 16:51:38 -0700
Message-ID: <AANLkTi=+uNFq5=5gmjfAOhngXqR8RS3dX3E2uEWG33Ot@mail.gmail.com>
Subject: Re: [PATCH 3/4] writeback: nr_dirtied and nr_entered_writeback in /proc/vmstat
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "jack@suse.cz" <jack@suse.cz>, "riel@redhat.com" <riel@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "david@fromorbit.com" <david@fromorbit.com>, "npiggin@kernel.dk" <npiggin@kernel.dk>, "hch@lst.de" <hch@lst.de>, "axboe@kernel.dk" <axboe@kernel.dk>
List-ID: <linux-mm.kvack.org>

On Fri, Aug 20, 2010 at 3:08 AM, Wu Fengguang <fengguang.wu@intel.com> wrot=
e:
> How about the names nr_dirty_accumulated and nr_writeback_accumulated?
> It seems more consistent, for both the interface and code (see below).
> I'm not really sure though.

Those names don't seem to right to me.
I admit I like "nr_dirtied" and "nr_cleaned" that seems most
understood. These numbers also get very big pretty fast so I don't
think it's hard to infer.

>> In order to track the "cleaned" and "dirtied" counts we added two
>> vm_stat_items. =A0Per memory node stats have been added also. So we can
>> see per node granularity:
>>
>> =A0 =A0# cat /sys/devices/system/node/node20/writebackstat
>> =A0 =A0Node 20 pages_writeback: 0 times
>> =A0 =A0Node 20 pages_dirtied: 0 times
>
> I'd prefer the name "vmstat" over "writebackstat", and propose to
> migrate items from /proc/zoneinfo over time. zoneinfo is a terrible
> interface for scripting.

I like vmstat also. I can do that.

> Also, are there meaningful usage of per-node writeback stats?

For us yes. We use fake numa nodes to implement cgroup memory isolation.
This allows us to see what the writeback behaviour is like per cgroup.

> The numbers are naturally per-bdi ones instead. But if we plan to
> expose them for each bdi, this patch will need to be implemented
> vastly differently.

Currently I have no plans to do that.

mrubin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

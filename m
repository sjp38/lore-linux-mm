Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 8E2086B007B
	for <linux-mm@kvack.org>; Wed, 15 Sep 2010 02:18:17 -0400 (EDT)
Received: from hpaq14.eem.corp.google.com (hpaq14.eem.corp.google.com [172.25.149.14])
	by smtp-out.google.com with ESMTP id o8F6IPg3012504
	for <linux-mm@kvack.org>; Tue, 14 Sep 2010 23:18:25 -0700
Received: from pwi9 (pwi9.prod.google.com [10.241.219.9])
	by hpaq14.eem.corp.google.com with ESMTP id o8F6IN23000794
	for <linux-mm@kvack.org>; Tue, 14 Sep 2010 23:18:24 -0700
Received: by pwi9 with SMTP id 9so52163pwi.30
        for <linux-mm@kvack.org>; Tue, 14 Sep 2010 23:18:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100913030256.GC7697@localhost>
References: <1284323440-23205-1-git-send-email-mrubin@google.com>
 <1284323440-23205-5-git-send-email-mrubin@google.com> <20100913030256.GC7697@localhost>
From: Michael Rubin <mrubin@google.com>
Date: Tue, 14 Sep 2010 23:18:03 -0700
Message-ID: <AANLkTinVKWmPUUxu4zHe8X6O-0yh3Hd=WFM5t7WaprTZ@mail.gmail.com>
Subject: Re: [PATCH 4/5] writeback: Adding /sys/devices/system/node/<node>/vmstat
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "jack@suse.cz" <jack@suse.cz>, "riel@redhat.com" <riel@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "david@fromorbit.com" <david@fromorbit.com>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "npiggin@kernel.dk" <npiggin@kernel.dk>, "hch@lst.de" <hch@lst.de>, "axboe@kernel.dk" <axboe@kernel.dk>
List-ID: <linux-mm.kvack.org>

On Sun, Sep 12, 2010 at 8:02 PM, Wu Fengguang <fengguang.wu@intel.com> wrote:
> Do you have plan to port more vmstat_text[] items? :)

Yes. I feel bound to do it after all your help. :-)
I may need a few weeks to resolve some other issues but I can get back to this.

mrubin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

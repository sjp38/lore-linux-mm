Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 9C91E6B00D9
	for <linux-mm@kvack.org>; Mon, 13 Sep 2010 01:45:54 -0400 (EDT)
Received: from hpaq14.eem.corp.google.com (hpaq14.eem.corp.google.com [172.25.149.14])
	by smtp-out.google.com with ESMTP id o8D5joAJ025999
	for <linux-mm@kvack.org>; Sun, 12 Sep 2010 22:45:52 -0700
Received: from pwi3 (pwi3.prod.google.com [10.241.219.3])
	by hpaq14.eem.corp.google.com with ESMTP id o8D5jmHo011480
	for <linux-mm@kvack.org>; Sun, 12 Sep 2010 22:45:49 -0700
Received: by pwi3 with SMTP id 3so2037078pwi.19
        for <linux-mm@kvack.org>; Sun, 12 Sep 2010 22:45:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100913031524.GD7697@localhost>
References: <1284323440-23205-1-git-send-email-mrubin@google.com>
 <1284323440-23205-6-git-send-email-mrubin@google.com> <20100913031524.GD7697@localhost>
From: Michael Rubin <mrubin@google.com>
Date: Sun, 12 Sep 2010 22:45:28 -0700
Message-ID: <AANLkTimCh=10XzoHYtW+3TdejbwXu_x-t8NVV5HXCgsA@mail.gmail.com>
Subject: Re: [PATCH 5/5] writeback: Reporting dirty thresholds in /proc/vmstat
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "jack@suse.cz" <jack@suse.cz>, "riel@redhat.com" <riel@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "david@fromorbit.com" <david@fromorbit.com>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "npiggin@kernel.dk" <npiggin@kernel.dk>, "hch@lst.de" <hch@lst.de>, "axboe@kernel.dk" <axboe@kernel.dk>
List-ID: <linux-mm.kvack.org>

On Sun, Sep 12, 2010 at 8:15 PM, Wu Fengguang <fengguang.wu@intel.com> wrote:

> But technical wise, the above two enum items should better be removed
> to avoid possibly eating one more cache line. The two items can be
> printed by explicit code.

Done. Patch coming.

mrubin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

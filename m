Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id DDCF06B01F1
	for <linux-mm@kvack.org>; Mon, 30 Aug 2010 12:26:17 -0400 (EDT)
Received: from wpaz24.hot.corp.google.com (wpaz24.hot.corp.google.com [172.24.198.88])
	by smtp-out.google.com with ESMTP id o7UGQEJB013691
	for <linux-mm@kvack.org>; Mon, 30 Aug 2010 09:26:14 -0700
Received: from gxk20 (gxk20.prod.google.com [10.202.11.20])
	by wpaz24.hot.corp.google.com with ESMTP id o7UGQDxY004096
	for <linux-mm@kvack.org>; Mon, 30 Aug 2010 09:26:13 -0700
Received: by gxk20 with SMTP id 20so2643059gxk.17
        for <linux-mm@kvack.org>; Mon, 30 Aug 2010 09:26:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100830092446.524B.A69D9226@jp.fujitsu.com>
References: <1282963227-31867-1-git-send-email-mrubin@google.com>
 <1282963227-31867-5-git-send-email-mrubin@google.com> <20100830092446.524B.A69D9226@jp.fujitsu.com>
From: Michael Rubin <mrubin@google.com>
Date: Mon, 30 Aug 2010 09:25:41 -0700
Message-ID: <AANLkTimLwv04pvuz_AtSK3ASr-epD0PeA-vOCigFH8+0@mail.gmail.com>
Subject: Re: [PATCH 4/4] writeback: Reporting dirty thresholds in /proc/vmstat
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, fengguang.wu@intel.com, jack@suse.cz, riel@redhat.com, akpm@linux-foundation.org, david@fromorbit.com, npiggin@kernel.dk, hch@lst.de, axboe@kernel.dk
List-ID: <linux-mm.kvack.org>

On Sun, Aug 29, 2010 at 5:28 PM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
> afaict, you and wu agreed /debug/bdi/default/stats is enough good.
> why do you change your mention?

I commented on this in the 0/4 email of the bug. I think these belong
in /proc/vmstat but I saw they exist in /debug/bdi/default/stats. I
figure they will probably not be accepted but I thought it was worth
attaching for consideration of upgrading from debugfs to /proc.

mrubin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

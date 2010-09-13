Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id B02936B00CE
	for <linux-mm@kvack.org>; Sun, 12 Sep 2010 22:58:38 -0400 (EDT)
Date: Mon, 13 Sep 2010 10:58:32 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 3/5] writeback: nr_dirtied and nr_written in
 /proc/vmstat
Message-ID: <20100913025831.GB7697@localhost>
References: <1284323440-23205-1-git-send-email-mrubin@google.com>
 <1284323440-23205-4-git-send-email-mrubin@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1284323440-23205-4-git-send-email-mrubin@google.com>
Sender: owner-linux-mm@kvack.org
To: Michael Rubin <mrubin@google.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "jack@suse.cz" <jack@suse.cz>, "riel@redhat.com" <riel@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "david@fromorbit.com" <david@fromorbit.com>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "npiggin@kernel.dk" <npiggin@kernel.dk>, "hch@lst.de" <hch@lst.de>, "axboe@kernel.dk" <axboe@kernel.dk>
List-ID: <linux-mm.kvack.org>

On Mon, Sep 13, 2010 at 04:30:38AM +0800, Michael Rubin wrote:
> To help developers and applications gain visibility into writeback
> behaviour adding two entries to vm_stat_items and /proc/vmstat. This
> will allow us to track the "written" and "dirtied" counts.
> 
>    # grep nr_dirtied /proc/vmstat
>    nr_dirtied 3747
>    # grep nr_written /proc/vmstat
>    nr_cleaned 3618

s/nr_cleaned/nr_written

Reviewed-by: Wu Fengguang <fengguang.wu@intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

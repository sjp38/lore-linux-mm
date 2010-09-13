Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 53B606B00CD
	for <linux-mm@kvack.org>; Sun, 12 Sep 2010 22:50:17 -0400 (EDT)
Date: Mon, 13 Sep 2010 10:50:10 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 2/5] mm: account_page_writeback added
Message-ID: <20100913025010.GA7697@localhost>
References: <1284323440-23205-1-git-send-email-mrubin@google.com>
 <1284323440-23205-3-git-send-email-mrubin@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1284323440-23205-3-git-send-email-mrubin@google.com>
Sender: owner-linux-mm@kvack.org
To: Michael Rubin <mrubin@google.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "jack@suse.cz" <jack@suse.cz>, "riel@redhat.com" <riel@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "david@fromorbit.com" <david@fromorbit.com>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "npiggin@kernel.dk" <npiggin@kernel.dk>, "hch@lst.de" <hch@lst.de>, "axboe@kernel.dk" <axboe@kernel.dk>
List-ID: <linux-mm.kvack.org>

On Mon, Sep 13, 2010 at 04:30:37AM +0800, Michael Rubin wrote:
> This allows code outside of the mm core to safely manipulate page
> writeback state and not worry about the other accounting. Not using
> these routines means that some code will lose track of the accounting
> and we get bugs.
> 
> Modified nilfs2 to use interface.
> 
> Signed-off-by: Michael Rubin <mrubin@google.com>
> Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Reviewed-by: Wu Fengguang <fengguang.wu@intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

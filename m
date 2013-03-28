Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id 451CC6B0005
	for <linux-mm@kvack.org>; Thu, 28 Mar 2013 14:23:08 -0400 (EDT)
Received: by mail-pb0-f54.google.com with SMTP id rq13so1873576pbb.41
        for <linux-mm@kvack.org>; Thu, 28 Mar 2013 11:23:07 -0700 (PDT)
Date: Thu, 28 Mar 2013 11:23:05 -0700
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 1/2] mm: remove CONFIG_HOTPLUG ifdefs
Message-ID: <20130328182305.GA12903@kroah.com>
References: <1364437418-9144-1-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1364437418-9144-1-git-send-email-wangyijing@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yijing Wang <wangyijing@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hanjun Guo <guohanjun@huawei.com>, jiang.liu@huawei.com, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Bill Pemberton <wfp5p@virginia.edu>

On Thu, Mar 28, 2013 at 10:23:38AM +0800, Yijing Wang wrote:
> CONFIG_HOTPLUG is going away as an option, cleanup CONFIG_HOTPLUG
> ifdefs in mm files.
> 
> Signed-off-by: Yijing Wang <wangyijing@huawei.com>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Bill Pemberton <wfp5p@virginia.edu>
> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

Acked-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

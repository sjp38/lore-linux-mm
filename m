Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id 4B6DB6B00AE
	for <linux-mm@kvack.org>; Mon,  8 Apr 2013 09:40:44 -0400 (EDT)
Message-ID: <5162C8CF.6070706@redhat.com>
Date: Mon, 08 Apr 2013 09:40:31 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [Resend with Ack][PATCH] mm: remove CONFIG_HOTPLUG ifdefs
References: <1365411202-8612-1-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1365411202-8612-1-git-send-email-wangyijing@huawei.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yijing Wang <wangyijing@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hanjun Guo <guohanjun@huawei.com>, jiang.liu@huawei.com, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Hugh Dickins <hughd@google.com>, Bill Pemberton <wfp5p@virginia.edu>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>

On 04/08/2013 04:53 AM, Yijing Wang wrote:
> CONFIG_HOTPLUG is going away as an option, cleanup CONFIG_HOTPLUG
> ifdefs in mm files.
>
> Signed-off-by: Yijing Wang <wangyijing@huawei.com>
> Acked-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Bill Pemberton <wfp5p@virginia.edu>
> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

Acked-by: Rik van Riel <riel@redhat.com>


-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

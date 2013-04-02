Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id CD5F56B0002
	for <linux-mm@kvack.org>; Tue,  2 Apr 2013 10:57:50 -0400 (EDT)
Message-ID: <515AF1E7.9020806@redhat.com>
Date: Tue, 02 Apr 2013 10:57:43 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/vmscan: fix error return in kswapd_run()
References: <515ABC79.5060900@huawei.com>
In-Reply-To: <515ABC79.5060900@huawei.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, hughd@google.com, khlebnikov@openvz.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hanjun Guo <guohanjun@huawei.com>, Zhangdianfang <zhangdianfang@huawei.com>

On 04/02/2013 07:09 AM, Xishi Qiu wrote:
> Fix the error return value in kswapd_run(). The bug was
> introduced by commit d5dc0ad928fb9e972001e552597fd0b794863f34
> "mm/vmscan: fix error number for failed kthread".
>
> Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id 64A5A6B0031
	for <linux-mm@kvack.org>; Mon, 16 Sep 2013 20:59:53 -0400 (EDT)
Message-ID: <5237A967.2060108@huawei.com>
Date: Tue, 17 Sep 2013 08:59:19 +0800
From: Jianguo Wu <wujianguo@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/mempolicy: use NUMA_NO_NODE
References: <5236FF32.60503@huawei.com> <52372F9A.1080102@gmail.com>
In-Reply-To: <52372F9A.1080102@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hugh
 Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 2013/9/17 0:19, KOSAKI Motohiro wrote:

> (9/16/13 8:53 AM), Jianguo Wu wrote:
>> Use more appropriate NUMA_NO_NODE instead of -1
>>
>> Signed-off-by: Jianguo Wu <wujianguo@huawei.com>
>> ---
>>   mm/mempolicy.c |   10 +++++-----
>>   1 files changed, 5 insertions(+), 5 deletions(-)
> 
> I think this patch don't make any functional change, right?
> 

Yes.

> Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Thanks for your ack.

> 
> 
> 
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 8CD4F6B004F
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 13:21:54 -0400 (EDT)
Message-ID: <4A5384A4.7060108@redhat.com>
Date: Tue, 07 Jul 2009 13:23:48 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/5] add isolate pages vmstat
References: <20090707090120.1e71a060.minchan.kim@barrios-desktop> <20090707090509.0C60.A69D9226@jp.fujitsu.com> <20090707101855.0C63.A69D9226@jp.fujitsu.com> <alpine.DEB.1.10.0907071248560.5124@gentwo.org>
In-Reply-To: <alpine.DEB.1.10.0907071248560.5124@gentwo.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Tue, 7 Jul 2009, KOSAKI Motohiro wrote:
> 
>> +++ b/include/linux/mmzone.h
>> @@ -100,6 +100,8 @@ enum zone_stat_item {
>>  	NR_BOUNCE,
>>  	NR_VMSCAN_WRITE,
>>  	NR_WRITEBACK_TEMP,	/* Writeback using temporary buffers */
>> +	NR_ISOLATED_ANON,	/* Temporary isolated pages from anon lru */
>> +	NR_ISOLATED_FILE,	/* Temporary isolated pages from file lru */
> 
> LRU counters are rarer in use then the counters used for dirty pages etc.
> 
> Could you move the counters for reclaim into a separate cacheline?

I don't get the point of that - these counters are
per-cpu anyway, so why would they need to be in a
separate cacheline?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id F20456B004D
	for <linux-mm@kvack.org>; Thu,  3 May 2012 11:27:01 -0400 (EDT)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Thu, 3 May 2012 09:27:01 -0600
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 013DF19D80AA
	for <linux-mm@kvack.org>; Thu,  3 May 2012 09:25:29 -0600 (MDT)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q43FOs87179314
	for <linux-mm@kvack.org>; Thu, 3 May 2012 09:25:11 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q43FO2bP009376
	for <linux-mm@kvack.org>; Thu, 3 May 2012 09:24:07 -0600
Message-ID: <4FA2A2F0.3030509@linux.vnet.ibm.com>
Date: Thu, 03 May 2012 10:23:28 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/4] zsmalloc use zs_handle instead of void *
References: <1336027242-372-1-git-send-email-minchan@kernel.org> <1336027242-372-3-git-send-email-minchan@kernel.org> <4FA28907.9020300@vflare.org>
In-Reply-To: <4FA28907.9020300@vflare.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nitin Gupta <ngupta@vflare.org>
Cc: Minchan Kim <minchan@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

On 05/03/2012 08:32 AM, Nitin Gupta wrote:

> On 5/3/12 2:40 AM, Minchan Kim wrote:
>> We should use zs_handle instead of void * to avoid any
>> confusion. Without this, users may just treat zs_malloc return value as
>> a pointer and try to deference it.
>>
>> Cc: Dan Magenheimer<dan.magenheimer@oracle.com>
>> Cc: Konrad Rzeszutek Wilk<konrad.wilk@oracle.com>
>> Signed-off-by: Minchan Kim<minchan@kernel.org>
>> ---
>>   drivers/staging/zcache/zcache-main.c     |    8 ++++----
>>   drivers/staging/zram/zram_drv.c          |    8 ++++----
>>   drivers/staging/zram/zram_drv.h          |    2 +-
>>   drivers/staging/zsmalloc/zsmalloc-main.c |   28
>> ++++++++++++++--------------
>>   drivers/staging/zsmalloc/zsmalloc.h      |   15 +++++++++++----
>>   5 files changed, 34 insertions(+), 27 deletions(-)
> 
> This was a long pending change. Thanks!


The reason I hadn't done it before is that it introduces a checkpatch
warning:

WARNING: do not add new typedefs
#303: FILE: drivers/staging/zsmalloc/zsmalloc.h:19:
+typedef void * zs_handle;

In addition this particular patch has a checkpatch error:

ERROR: "foo * bar" should be "foo *bar"
#303: FILE: drivers/staging/zsmalloc/zsmalloc.h:19:
+typedef void * zs_handle;

--
Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

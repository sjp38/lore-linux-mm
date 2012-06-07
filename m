Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 89A6F6B0062
	for <linux-mm@kvack.org>; Wed,  6 Jun 2012 22:45:52 -0400 (EDT)
Message-ID: <4FD015FE.7070906@kernel.org>
Date: Thu, 07 Jun 2012 11:46:22 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] zram: clean up handle
References: <1338881031-19662-1-git-send-email-minchan@kernel.org> <1338881031-19662-2-git-send-email-minchan@kernel.org> <4FCEE4E0.6030707@vflare.org>
In-Reply-To: <4FCEE4E0.6030707@vflare.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nitin Gupta <ngupta@vflare.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>

On 06/06/2012 02:04 PM, Nitin Gupta wrote:

> On 06/05/2012 12:23 AM, Minchan Kim wrote:
> 
>> zram's handle variable can store handle of zsmalloc in case of
>> compressing efficiently. Otherwise, it stores point of page descriptor.
>> This patch clean up the mess by union struct.
>>
>> changelog
>>   * from v1
>> 	- none(new add in v2)
>>
>> Cc: Nitin Gupta <ngupta@vflare.org>
>> Acked-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
>> Acked-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
>> Signed-off-by: Minchan Kim <minchan@kernel.org>
>> ---
>>  drivers/staging/zram/zram_drv.c |   77 ++++++++++++++++++++-------------------
>>  drivers/staging/zram/zram_drv.h |    5 ++-
>>  2 files changed, 44 insertions(+), 38 deletions(-)
>>
> 
> 
> I think page vs handle distinction was added since xvmalloc could not
> handle full page allocation. Now that zsmalloc allows full page


I see. I didn't know that because I'm blind on xvmalloc.

> allocation, we can just use it for both cases. This would also allow
> removing the ZRAM_UNCOMPRESSED flag. The only downside will be slightly
> slower code path for full page allocation but this event is anyways
> supposed to be rare, so should be fine.


Fair enough.
It can remove many code of zram.
Okay. Will look into that.

Thanks.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

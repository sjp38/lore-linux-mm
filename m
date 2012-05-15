Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id A45BB6B00E9
	for <linux-mm@kvack.org>; Mon, 14 May 2012 22:30:52 -0400 (EDT)
Message-ID: <4FB1BFFC.8080405@kernel.org>
Date: Tue, 15 May 2012 11:31:24 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH 2/3] zram: remove comment in Kconfig
References: <1336985134-31967-1-git-send-email-minchan@kernel.org> <1336985134-31967-2-git-send-email-minchan@kernel.org> <4FB119CA.2080606@linux.vnet.ibm.com>
In-Reply-To: <4FB119CA.2080606@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 05/14/2012 11:42 PM, Seth Jennings wrote:

> On 05/14/2012 03:45 AM, Minchan Kim wrote:
> 
>> Exactly speaking, zram should has dependency with
>> zsmalloc, not x86. So x86 dependeny check is redundant.
>>
>> Signed-off-by: Minchan Kim <minchan@kernel.org>
>> ---
>>  drivers/staging/zram/Kconfig |    4 +---
>>  1 file changed, 1 insertion(+), 3 deletions(-)
>>
>> diff --git a/drivers/staging/zram/Kconfig b/drivers/staging/zram/Kconfig
>> index 9d11a4c..ee23a86 100644
>> --- a/drivers/staging/zram/Kconfig
>> +++ b/drivers/staging/zram/Kconfig
>> @@ -1,8 +1,6 @@
>>  config ZRAM
>>  	tristate "Compressed RAM block device support"
>> -	# X86 dependency is because zsmalloc uses non-portable pte/tlb
>> -	# functions
>> -	depends on BLOCK && SYSFS && X86
>> +	depends on BLOCK && SYSFS
> 
> 
> Two comments here:
> 
> 1) zram should really depend on ZSMALLOC instead of selecting it
> because, as the patch has it, zram could be selected on an arch that
> zsmalloc doesn't support.


Argh, Totally my mistake. my patch didn't match with my comment, either. :(

> 
> 2) This change would need to be done in zcache as well.


I see.
Seth, Thanks.

send v2.

== CUT_HERE ==

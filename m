Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 22BCF6B004D
	for <linux-mm@kvack.org>; Mon,  9 Apr 2012 16:24:39 -0400 (EDT)
Received: from /spool/local
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Mon, 9 Apr 2012 14:24:38 -0600
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id C56D019D8053
	for <linux-mm@kvack.org>; Mon,  9 Apr 2012 14:23:36 -0600 (MDT)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q39KNgms154480
	for <linux-mm@kvack.org>; Mon, 9 Apr 2012 14:23:44 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q39KNf9O008100
	for <linux-mm@kvack.org>; Mon, 9 Apr 2012 14:23:42 -0600
Message-ID: <4F83454A.3050007@linux.vnet.ibm.com>
Date: Mon, 09 Apr 2012 15:23:38 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH] staging: zsmalloc: fix memory leak
References: <<1333376036-9841-1-git-send-email-sjenning@linux.vnet.ibm.com>> <d858d87f-6e07-4303-a9b3-e41ff93c8080@default> <4F7C7626.40506@linux.vnet.ibm.com>
In-Reply-To: <4F7C7626.40506@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Dan Magenheimer <dan.magenheimer@oracle.com>, Nitin Gupta <ngupta@vflare.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hey Greg,

Haven't heard back from you on this patch and it needs to
get into the 3.4 -rc releases ASAP.  It fixes a substantial
memory leak when frontswap/zcache are enabled.

Let me know if you need me to repost.

The patch was sent on 4/2.

Thanks,
Seth

On 04/04/2012 11:26 AM, Seth Jennings wrote:
> On 04/04/2012 11:03 AM, Dan Magenheimer wrote:
>>> From: Seth Jennings [mailto:sjenning@linux.vnet.ibm.com]
>>> Sent: Monday, April 02, 2012 8:14 AM
>>> To: Greg Kroah-Hartman
>>> Cc: Nitin Gupta; Dan Magenheimer; Konrad Rzeszutek Wilk; Robert Jennings; Seth Jennings;
>>> devel@driverdev.osuosl.org; linux-kernel@vger.kernel.org; linux-mm@kvack.org
>>> Subject: [PATCH] staging: zsmalloc: fix memory leak
>>>
>>> From: Nitin Gupta <ngupta@vflare.org>
>>>
>>> This patch fixes a memory leak in zsmalloc where the first
>>> subpage of each zspage is leaked when the zspage is freed.
>>>
>>> Based on 3.4-rc1.
>>>
>>> Signed-off-by: Nitin Gupta <ngupta@vflare.org>
>>> Acked-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
>>
>> This is a rather severe memory leak and will affect most
>> benchmarking anyone does to evaluate zcache in 3.4 (e.g. as
>> to whether zcache is suitable for promotion), so t'would be nice
>> to get this patch in for -rc2.  (Note it fixes a "regression"
>> since it affects zcache only in 3.4+ because the fix is to
>> the new zsmalloc allocator... so no change to stable trees.)
>>
>> Acked-by: Dan Magenheimer <dan.magenheimer@oracle.com>
> 
> Thanks Dan for this clarification and the Ack.
> 
> I should have tagged this as urgent for the 3.4 release
> and no impact on stable trees, since 3.4 is the first release
> with this code.
> 
> --
> Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

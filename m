Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id 133F56B0081
	for <linux-mm@kvack.org>; Mon, 21 May 2012 05:07:42 -0400 (EDT)
Received: from /spool/local
	by e06smtp16.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ehrhardt@linux.vnet.ibm.com>;
	Mon, 21 May 2012 10:07:40 +0100
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q4L97GT41249380
	for <linux-mm@kvack.org>; Mon, 21 May 2012 10:07:16 +0100
Received: from d06av03.portsmouth.uk.ibm.com (localhost.localdomain [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q4L97F2m022005
	for <linux-mm@kvack.org>; Mon, 21 May 2012 03:07:15 -0600
Message-ID: <4FBA05C2.5090306@linux.vnet.ibm.com>
Date: Mon, 21 May 2012 11:07:14 +0200
From: Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] swap: allow swap readahead to be merged
References: <1337587755-4743-1-git-send-email-ehrhardt@linux.vnet.ibm.com> <1337587755-4743-2-git-send-email-ehrhardt@linux.vnet.ibm.com> <4FBA0203.20509@kernel.org>
In-Reply-To: <4FBA0203.20509@kernel.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, axboe@kernel.dk



On 05/21/2012 10:51 AM, Minchan Kim wrote:
> On 05/21/2012 05:09 PM, ehrhardt@linux.vnet.ibm.com wrote:
>
>> From: Christian Ehrhardt<ehrhardt@linux.vnet.ibm.com>
>>
[...]
>>
>> Signed-off-by: Christian Ehrhardt<ehrhardt@linux.vnet.ibm.com>
>> Acked-by: Rik van Riel<riel@redhat.com>
>> Acked-by: Jens Axboe<axboe@kernel.dk>
>
>
> Reviewed-by: Minchan Kim<minchan@kernel.org>
>
> Didn't I add my Reviewed-by on your previous version?
>

Sorry I missed it since you provided the good feedback on all three 
mails. I had your "otherwise looks good to me to mail #2" still in mind 
and didn't want to be so offensive to convert that to a review or ack 
statement.

-- 

GrA 1/4 sse / regards, Christian Ehrhardt
IBM Linux Technology Center, System z Linux Performance

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

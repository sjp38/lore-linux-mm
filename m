Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 103DB6B0081
	for <linux-mm@kvack.org>; Mon, 21 May 2012 03:25:25 -0400 (EDT)
Received: from /spool/local
	by e06smtp17.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ehrhardt@linux.vnet.ibm.com>;
	Mon, 21 May 2012 08:25:22 +0100
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by d06nrmr1806.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q4L7OrOc2474212
	for <linux-mm@kvack.org>; Mon, 21 May 2012 08:24:54 +0100
Received: from d06av04.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q4L7OoNG021594
	for <linux-mm@kvack.org>; Mon, 21 May 2012 01:24:50 -0600
Message-ID: <4FB9EDC1.3070401@linux.vnet.ibm.com>
Date: Mon, 21 May 2012 09:24:49 +0200
From: Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] documentation: update how page-cluster affects swap
 I/O
References: <1336996709-8304-1-git-send-email-ehrhardt@linux.vnet.ibm.com> <1336996709-8304-3-git-send-email-ehrhardt@linux.vnet.ibm.com> <4FB1E00F.2000903@kernel.org>
In-Reply-To: <4FB1E00F.2000903@kernel.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, axboe@kernel.dk, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>



On 05/15/2012 06:48 AM, Minchan Kim wrote:
> On 05/14/2012 08:58 PM, ehrhardt@linux.vnet.ibm.com wrote:
>
>> From: Christian Ehrhardt<ehrhardt@linux.vnet.ibm.com>
>>
>> Fix of the documentation of /proc/sys/vm/page-cluster to match the behavior of
>> the code and add some comments about what the tunable will change in that
>> behavior.
>>
>> Signed-off-by: Christian Ehrhardt<ehrhardt@linux.vnet.ibm.com>
>> ---
>>   Documentation/sysctl/vm.txt |   12 ++++++++++--
>>   1 files changed, 10 insertions(+), 2 deletions(-)
>>
>> diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
>> index 96f0ee8..4d87dc0 100644
>> --- a/Documentation/sysctl/vm.txt
>> +++ b/Documentation/sysctl/vm.txt
>> @@ -574,16 +574,24 @@ of physical RAM.  See above.
>>
>>   page-cluster
>>
>> -page-cluster controls the number of pages which are written to swap in
>> -a single attempt.  The swap I/O size.
>> +page-cluster controls the number of pages up to which consecutive pages (if
>> +available) are read in from swap in a single attempt. This is the swap
>
>
> "If available" would be wrong in next kernel because recently Rik submit following patch,
>
> mm: make swapin readahead skip over holes
> http://marc.info/?l=linux-mm&m=132743264912987&w=4
>
>

You're right - its not severely wrong, but if we are fixing the 
documentation we can do it right.
I'll send a 2nd version of the patch series with this adapted and all 
the acks I got so far added.

-- 

GrA 1/4 sse / regards, Christian Ehrhardt
IBM Linux Technology Center, System z Linux Performance

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

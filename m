Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l6AIYBN4016585
	for <linux-mm@kvack.org>; Tue, 10 Jul 2007 14:34:11 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l6AIY47R033126
	for <linux-mm@kvack.org>; Tue, 10 Jul 2007 12:34:08 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l6AIY1RR022752
	for <linux-mm@kvack.org>; Tue, 10 Jul 2007 12:34:01 -0600
Message-ID: <4693D126.2030004@us.ibm.com>
Date: Tue, 10 Jul 2007 11:34:14 -0700
From: Badari Pulavarty <pbadari@us.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] hugetlbfs read support
References: <1184009291.31638.8.camel@dyn9047017100.beaverton.ibm.com> <20070710153752.GV26380@holomorphy.com> <20070710154312.GE27655@us.ibm.com> <20070710161217.GX26380@holomorphy.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Bill Irwin <bill.irwin@oracle.com>
Cc: Nishanth Aravamudan <nacc@us.ibm.com>, Linux Memory Management <linux-mm@kvack.org>, clameter@sgi.com, agl@us.ibm.com
List-ID: <linux-mm.kvack.org>


Bill Irwin wrote:

>On 10.07.2007 [08:37:52 -0700], Bill Irwin wrote:
>
>>>What's the testing status of all this? I thoroughly approve of the
>>>concept, of course.
>>>
>
>On Tue, Jul 10, 2007 at 08:43:12AM -0700, Nishanth Aravamudan wrote:
>
>>With this change, OProfile is able to do symbol lookup (which is
>>achieved via libbfd, which does reads() of the appropriate files) with
>>relinked binaries in post-processing. The file utility is also able to
>>recognize persistent text segments as ELF executables.
>>If you would like further testing, let me know what.
>>
>
>That's good enough for me.
>
>Acked-by: William Irwin <bill.irwin@oracle.com>
>
Thanks. I may have to handle memcpy() failures. I will fix that and send 
out a patch.

Thanks,
Badari




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m4RHJIrt030153
	for <linux-mm@kvack.org>; Tue, 27 May 2008 13:19:18 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m4RHJIkR103618
	for <linux-mm@kvack.org>; Tue, 27 May 2008 11:19:18 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m4RHJHf1008238
	for <linux-mm@kvack.org>; Tue, 27 May 2008 11:19:18 -0600
Message-ID: <483C42B9.7090102@linux.vnet.ibm.com>
Date: Tue, 27 May 2008 12:19:53 -0500
From: Jon Tollefson <kniht@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [patch 22/23] fs: check for statfs overflow
References: <20080525142317.965503000@nick.local0.net> <20080525143454.453947000@nick.local0.net> <20080527171452.GJ20709@us.ibm.com>
In-Reply-To: <20080527171452.GJ20709@us.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: npiggin@suse.de, linux-mm@kvack.org, andi@firstfloor.org, agl@us.ibm.com, abh@cray.com, joachim.deguara@amd.com, Jon Tollefson <kniht@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

Nishanth Aravamudan wrote:
> On 26.05.2008 [00:23:39 +1000], npiggin@suse.de wrote:
>   
>> Adds a check for an overflow in the filesystem size so if someone is
>> checking with statfs() on a 16G hugetlbfs  in a 32bit binary that it
>> will report back EOVERFLOW instead of a size of 0.
>>
>> Are other places that need a similar check?  I had tried a similar
>> check in put_compat_statfs64 too but it didn't seem to generate an
>> EOVERFLOW in my test case.
>>     
>
> I think this part of the changelog was meant to be a post-"---"
> question, which I don't have an answer for, but probably shouldn't go in
> the final changelog?
>   
You are correct.
>   
>> Signed-off-by: Jon Tollefson <kniht@linux.vnet.ibm.com>
>> Signed-off-by: Nick Piggin <npiggin@suse.de>
>>     
>
> Acked-by: Nishanth Aravamudan <nacc@us.ibm.com>
>
> Thanks,
> Nish
>
>   
Jon

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

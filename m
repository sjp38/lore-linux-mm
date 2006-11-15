Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e4.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id kAFIHL2f029037
	for <linux-mm@kvack.org>; Wed, 15 Nov 2006 13:17:21 -0500
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id kAFIGoHH123122
	for <linux-mm@kvack.org>; Wed, 15 Nov 2006 13:16:58 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id kAFIGo87011360
	for <linux-mm@kvack.org>; Wed, 15 Nov 2006 13:16:50 -0500
Message-ID: <455B5990.7080808@us.ibm.com>
Date: Wed, 15 Nov 2006 10:16:48 -0800
From: Badari Pulavarty <pbadari@us.ibm.com>
MIME-Version: 1.0
Subject: Re: pagefault in generic_file_buffered_write() causing deadlock
References: <1163606265.7662.8.camel@dyn9047017100.beaverton.ibm.com> <20061115090005.c9ec6db5.akpm@osdl.org>
In-Reply-To: <20061115090005.c9ec6db5.akpm@osdl.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm <linux-mm@kvack.org>, ext4 <linux-ext4@vger.kernel.org>, lkml <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> On Wed, 15 Nov 2006 07:57:45 -0800
> Badari Pulavarty <pbadari@us.ibm.com> wrote:
>
>   
>> We are looking at a customer situation (on 2.6.16-based distro) - where
>> system becomes almost useless while running some java & stress tests.
>>
>> Root cause seems to be taking a pagefault in generic_file_buffered_write
>> () after calling prepare_write. I am wondering 
>>
>> 1) Why & How this can happen - since we made sure to fault the user
>> buffer before prepare write.
>>     
>
> When using writev() we only fault in the first segment of the iovec.  If
> the second or succesive segment isn't mapped into pagetables we're
> vulnerable to the deadlock.
>   

Yes. I remember this change. Thank you.
>   
>> 2) If this is already fixed in current mainline (I can't see how).
>>     
>
> It was fixed in 2.6.17.
>
> You'll need 6527c2bdf1f833cc18e8f42bd97973d583e4aa83 and
> 81b0c8713385ce1b1b9058e916edcf9561ad76d6
>   
I will try to get this change into customer :(

Thanks,
Badari

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

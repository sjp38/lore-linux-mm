Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 422006B003D
	for <linux-mm@kvack.org>; Sun,  3 May 2009 05:06:01 -0400 (EDT)
Message-ID: <49FD5E96.6060301@redhat.com>
Date: Sun, 03 May 2009 12:06:30 +0300
From: Izik Eidus <ieidus@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/6] ksm: limiting the num of mem regions user can register
 per fd.
References: <1241302572-4366-1-git-send-email-ieidus@redhat.com>	<1241302572-4366-2-git-send-email-ieidus@redhat.com> <20090502220829.392b7ff9@riellaptop.surriel.com>
In-Reply-To: <20090502220829.392b7ff9@riellaptop.surriel.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@surriel.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, aarcange@redhat.com, chrisw@redhat.com, alan@lxorguk.ukuu.org.uk, device@lanana.org, linux-mm@kvack.org, hugh@veritas.com, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> On Sun,  3 May 2009 01:16:07 +0300
> Izik Eidus <ieidus@redhat.com> wrote:
>
>   
>> Right now user can open /dev/ksm fd and register unlimited number of
>> regions, such behavior may allocate unlimited amount of kernel memory
>> and get the whole host into out of memory situation.
>>     
>
> How many times can a process open /dev/ksm?
>
> If a process can open /dev/ksm a thousand times and then
> register 1000 regions through each file descriptor, this
> patch does not help all that much...
>
>   
The idea is that the limitation is now on the maximum file descriptors 
user can open.
So for each such file descriptor user can open 1024 structures that are 
just few bytes each.

The whole propose of this patch is to avoid while (1) { 
IOCTL(REGISTER_MEMORY_REGION) } and oom the host.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 3DB606B01E3
	for <linux-mm@kvack.org>; Sun, 25 Apr 2010 08:06:19 -0400 (EDT)
Message-ID: <4BD43033.7090706@redhat.com>
Date: Sun, 25 Apr 2010 15:06:11 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: Frontswap [PATCH 0/4] (was Transcendent Memory): overview
References: <20100422134249.GA2963@ca-server1.us.oracle.com> <4BD06B31.9050306@redhat.com> <53c81c97-b30f-4081-91a1-7cef1879c6fa@default> <4BD07594.9080905@redhat.com> <b1036777-129b-4531-a730-1e9e5a87cea9@default> <4BD16D09.2030803@redhat.com> <b01d7882-1a72-4ba9-8f46-ba539b668f56@default> <4BD1A74A.2050003@redhat.com> <4830bd20-77b7-46c8-994b-8b4fa9a79d27@default> <4BD1B427.9010905@redhat.com> <4BD1B626.7020702@redhat.com> <5fa93086-b0d7-4603-bdeb-1d6bfca0cd08@default 4BD3377E.6010303@redhat.com> <1c02a94a-a6aa-4cbb-a2e6-9d4647760e91@default>
In-Reply-To: <1c02a94a-a6aa-4cbb-a2e6-9d4647760e91@default>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, hugh.dickins@tiscali.co.uk, ngupta@vflare.org, JBeulich@novell.com, chris.mason@oracle.com, kurt.hackel@oracle.com, dave.mccracken@oracle.com, npiggin@suse.de, akpm@linux-foundation.org, riel@redhat.com
List-ID: <linux-mm.kvack.org>

On 04/25/2010 03:41 AM, Dan Magenheimer wrote:
>>> No, ANY put_page can fail, and this is a critical part of the API
>>> that provides all of the flexibility for the hypervisor and all
>>> the guests. (See previous reply.)
>>>        
>> The guest isn't required to do any put_page()s.  It can issue lots of
>> them when memory is available, and keep them in the hypervisor forever.
>> Failing new put_page()s isn't enough for a dynamic system, you need to
>> be able to force the guest to give up some of its tmem.
>>      
> Yes, indeed, this is true.  That is why it is important for any
> policy implemented behind frontswap to "bill" the guest if it
> is attempting to keep frontswap pages in the hypervisor forever
> and to prod the guest to reclaim them when it no longer needs
> super-fast emergency swap space.  The frontswap patch already includes
> the kernel mechanism to enable this and the prodding can be implemented
> by a guest daemon (of which there already exists an existence proof).
>    

In this case you could use the same mechanism to stop new put_page()s?

Seems frontswap is like a reverse balloon, where the balloon is in 
hypervisor space instead of the guest space.

> (While devil's advocacy is always welcome, frontswap is NOT a
> cool academic science project where these issues have not been
> considered or tested.)
>    


Good to know.

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

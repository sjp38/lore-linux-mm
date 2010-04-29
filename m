Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id C375C6B0209
	for <linux-mm@kvack.org>; Thu, 29 Apr 2010 14:59:23 -0400 (EDT)
Message-ID: <4BD9D702.90209@redhat.com>
Date: Thu, 29 Apr 2010 21:59:14 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: Frontswap [PATCH 0/4] (was Transcendent Memory): overview
References: <4BD16D09.2030803@redhat.com> <b01d7882-1a72-4ba9-8f46-ba539b668f56@default> <4BD1A74A.2050003@redhat.com> <4830bd20-77b7-46c8-994b-8b4fa9a79d27@default> <4BD1B427.9010905@redhat.com> <4BD1B626.7020702@redhat.com> <5fa93086-b0d7-4603-bdeb-1d6bfca0cd08@default> <4BD3377E.6010303@redhat.com> <1c02a94a-a6aa-4cbb-a2e6-9d4647760e91@default4BD43033.7090706@redhat.com> <ce808441-fae6-4a33-8335-f7702740097a@default 20100428055538.GA1730@ucw.cz> <c2744f69-5974-4017-ae33-4244ce0960e2@default>
In-Reply-To: <c2744f69-5974-4017-ae33-4244ce0960e2@default>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, hugh.dickins@tiscali.co.uk, ngupta@vflare.org, JBeulich@novell.com, chris.mason@oracle.com, kurt.hackel@oracle.com, dave.mccracken@oracle.com, npiggin@suse.de, akpm@linux-foundation.org, riel@redhat.com
List-ID: <linux-mm.kvack.org>

On 04/29/2010 05:42 PM, Dan Magenheimer wrote:
>>
>> Yes, and that set of hooks is new API, right?
>>      
> Well, no, if you define API as "application programming interface"
> this is NOT exposed to userland.  If you define API as a new
> in-kernel function call, yes, these hooks are a new API, but that
> is true of virtually any new code in the kernel.  If you define
> API as some new interface between the kernel and a hypervisor,
> yes, this is a new API, but it is "optional" at several levels
> so that any hypervisor (e.g. KVM) can completely ignore it.
>    

The concern is not with the hypervisor, but with Linux.  More external 
APIs reduce our flexibility to change things.

> So please let's not argue about whether the code is a "new API"
> or not, but instead consider whether the concept is useful or not
> and if useful, if there is or is not a cleaner way to implement it.
>    

I'm convinced it's useful.  The API is so close to a block device 
(read/write with key/value vs read/write with sector/value) that we 
should make the effort not to introduce a new API.

-- 
I have a truly marvellous patch that fixes the bug which this
signature is too narrow to contain.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

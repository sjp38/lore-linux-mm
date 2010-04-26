Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 792CC6B0208
	for <linux-mm@kvack.org>; Mon, 26 Apr 2010 09:43:30 -0400 (EDT)
Message-ID: <4BD5987F.7080505@redhat.com>
Date: Mon, 26 Apr 2010 16:43:27 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: Frontswap [PATCH 0/4] (was Transcendent Memory): overview
References: <20100422134249.GA2963@ca-server1.us.oracle.com> <4BD06B31.9050306@redhat.com> <53c81c97-b30f-4081-91a1-7cef1879c6fa@default> <4BD07594.9080905@redhat.com> <b1036777-129b-4531-a730-1e9e5a87cea9@default> <4BD16D09.2030803@redhat.com> <b01d7882-1a72-4ba9-8f46-ba539b668f56@default> <4BD1A74A.2050003@redhat.com> <4830bd20-77b7-46c8-994b-8b4fa9a79d27@default> <4BD1B427.9010905@redhat.com> <4BD24E37.30204@vflare.org> <4BD33822.2000604@redhat.com> <4BD3B2D1.8080203@vflare.org> <4BD4329A.9010509@redhat.com> <4BD4684E.9040802@vflare.org 4BD52D55.3070803@redhat.com> <2634f2cb-3e7e-4c86-b7ef-cf4a3f1e0d8a@default>
In-Reply-To: <2634f2cb-3e7e-4c86-b7ef-cf4a3f1e0d8a@default>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: ngupta@vflare.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, hugh.dickins@tiscali.co.uk, JBeulich@novell.com, chris.mason@oracle.com, kurt.hackel@oracle.com, dave.mccracken@oracle.com, npiggin@suse.de, akpm@linux-foundation.org, riel@redhat.com
List-ID: <linux-mm.kvack.org>

On 04/26/2010 03:50 PM, Dan Magenheimer wrote:
>>> Maybe incremental development is better? Stabilize and refine
>>>        
>> existing
>>      
>>> code and gradually move to async API, if required in future?
>>>        
>> Incremental development is fine, especially for ramzswap where the APIs
>> are all internal.  I'm more worried about external interfaces, these
>> stick around a lot longer and if not done right they're a pain forever.
>>      
> Well if you are saying that your primary objection to the
> frontswap synchronous API is that it is exposed to modules via
> some EXPORT_SYMBOLs, we can certainly fix that, at least
> unless/until there are other pseudo-RAM devices that can use it.
>
> Would that resolve your concerns?
>    

By external interfaces I mean the guest/hypervisor interface.  
EXPORT_SYMBOL is an internal interface as far as I'm concerned.

Now, the frontswap interface is also an internal interface, but it's 
close to the external one.  I'd feel much better if it was asynchronous.

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id B4FCF6B01E3
	for <linux-mm@kvack.org>; Fri, 23 Apr 2010 05:49:06 -0400 (EDT)
Message-ID: <4BD16D09.2030803@redhat.com>
Date: Fri, 23 Apr 2010 12:48:57 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: Frontswap [PATCH 0/4] (was Transcendent Memory): overview
References: <20100422134249.GA2963@ca-server1.us.oracle.com> <4BD06B31.9050306@redhat.com> <53c81c97-b30f-4081-91a1-7cef1879c6fa@default 4BD07594.9080905@redhat.com> <b1036777-129b-4531-a730-1e9e5a87cea9@default>
In-Reply-To: <b1036777-129b-4531-a730-1e9e5a87cea9@default>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, hugh.dickins@tiscali.co.uk, ngupta@vflare.org, JBeulich@novell.com, chris.mason@oracle.com, kurt.hackel@oracle.com, dave.mccracken@oracle.com, npiggin@suse.de, akpm@linux-foundation.org, riel@redhat.com
List-ID: <linux-mm.kvack.org>

On 04/22/2010 11:15 PM, Dan Magenheimer wrote:
>>
>> Much easier to simulate an asynchronous API with a synchronous backend.
>>      
> Indeed.  But an asynchronous API is not appropriate for frontswap
> (or cleancache).  The reason the hooks are so simple is because they
> are assumed to be synchronous so that the page can be immediately
> freed/reused.
>    

Swapping is inherently asynchronous, so we'll have to wait for that to 
complete anyway (as frontswap does not guarantee swap-in will succeed).  
I don't doubt it makes things simpler, but also less flexible and useful.

Something else that bothers me is the double swapping.  Sure we're 
making swapin faster, but we we're still loading the io subsystem with 
writes.  Much better to make swap-to-ram authoritative (and have the 
hypervisor swap it to disk if it needs the memory).

>> Well, copying memory so you can use a zero-copy dma engine is
>> counterproductive.
>>      
> Yes, but for something like an SSD where copying can be used to
> build up a full 64K write, the cost of copying memory may not be
> counterproductive.
>    

I don't understand.  Please clarify.

-- 
Do not meddle in the internals of kernels, for they are subtle and quick to panic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

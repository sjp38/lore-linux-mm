Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 92A206B01EF
	for <linux-mm@kvack.org>; Tue, 27 Apr 2010 05:21:15 -0400 (EDT)
Message-ID: <4BD6AC85.9000009@redhat.com>
Date: Tue, 27 Apr 2010 12:21:09 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: Frontswap [PATCH 0/4] (was Transcendent Memory): overview
References: <20100422134249.GA2963@ca-server1.us.oracle.com> <4BD06B31.9050306@redhat.com> <53c81c97-b30f-4081-91a1-7cef1879c6fa@default> <4BD07594.9080905@redhat.com> <b1036777-129b-4531-a730-1e9e5a87cea9@default> <4BD16D09.2030803@redhat.com> <b01d7882-1a72-4ba9-8f46-ba539b668f56@default> <4BD1A74A.2050003@redhat.com> <4830bd20-77b7-46c8-994b-8b4fa9a79d27@default> <4BD1B427.9010905@redhat.com> <4BD24E37.30204@vflare.org> <4BD33822.2000604@redhat.com> <4BD3B2D1.8080203@vflare.org> <4BD4329A.9010509@redhat.com> <4BD4684E.9040802@vflare.org> <4BD52D55.3070803@redhat.com> <2634f2cb-3e7e-4c86-b7ef-cf4a3f1e0d8a@default 4BD5987F.7080505@redhat.com> <a0c1615e-c64a-4d4a-bd49-9e3e614d031b@default>
In-Reply-To: <a0c1615e-c64a-4d4a-bd49-9e3e614d031b@default>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: ngupta@vflare.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, hugh.dickins@tiscali.co.uk, JBeulich@novell.com, chris.mason@oracle.com, kurt.hackel@oracle.com, dave.mccracken@oracle.com, npiggin@suse.de, akpm@linux-foundation.org, riel@redhat.com
List-ID: <linux-mm.kvack.org>

On 04/27/2010 11:29 AM, Dan Magenheimer wrote:
>
> OK, so on the one hand, you think that the proposed synchronous
> interface for frontswap is insufficiently extensible for other
> uses (presumably including KVM).  On the other hand, you agree
> that using the existing I/O subsystem is unnecessarily heavyweight.
> On the third hand, Nitin has answered your questions and spent
> a good part of three years finding that extending the existing swap
> interface to efficiently support swap-to-pseudo-RAM requires
> some kind of in-kernel notification mechanism to which Linus
> has already objected.
>
> So you are instead proposing some new guest-to-host asynchronous
> notification mechanism that doesn't use the existing bio
> mechanism (and so presumably not irqs),

(any notification mechanism has to use irqs if it exits the guest)

> imitates or can
> utilize a dma engine, and uses less cpu cycles than copying
> pages.  AND, for long-term maintainability, you'd like to avoid
> creating a new guest-host API that does all this, even one that
> is as simple and lightweight as the proposed frontswap hooks.
>
> Does that summarize your objection well?
>    

No.  Adding a new async API that parallels the block layer would be 
madness.  My first preference would be to completely avoid new APIs.  I 
think that would work for swap-to-hypervisor but probably not for 
compcache.  Second preference is the synchronous API, third is a new 
async API.

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

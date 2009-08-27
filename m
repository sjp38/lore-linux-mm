Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 888046B004F
	for <linux-mm@kvack.org>; Thu, 27 Aug 2009 04:39:35 -0400 (EDT)
Message-ID: <4A96463E.5080002@corp.free.fr>
Date: Thu, 27 Aug 2009 10:39:26 +0200
From: Yohan <ytordjman@corp.free.fr>
MIME-Version: 1.0
Subject: Re: VM issue causing high CPU loads
References: <4A92A25A.4050608@yohan.staff.proxad.net> <20090824162155.ce323f08.akpm@linux-foundation.org>
In-Reply-To: <20090824162155.ce323f08.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> On Mon, 24 Aug 2009 16:23:22 +0200
> Yohan <kernel@yohan.staff.proxad.net> wrote:
>   
>> Hi,
>>
>>     Is someone have an idea for that :
>>
>>         http://bugzilla.kernel.org/show_bug.cgi?id=14024
>>     
> Please generate a kernel profile to work out where all the CPU tie is
> being spent.  Documentation/basic_profiling.txt is a starting point.
>   
I post some new reports, it seems that the problem is in  
rpcauth_lookup_credcache ...

for information, this is an imap mail server that mounts ~10 netapp over 
~300 mountpoints..

Thanks
Yohan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

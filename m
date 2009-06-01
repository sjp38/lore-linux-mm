Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 095836B005C
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 10:52:14 -0400 (EDT)
Message-ID: <4A242F94.9010704@redhat.com>
Date: Mon, 01 Jun 2009 22:44:20 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] Warn if we run out of swap space
References: <alpine.DEB.1.10.0905221454460.7673@qirst.com>	<4A23FF89.2060603@redhat.com> <20090601123503.2337a79b.akpm@linux-foundation.org>
In-Reply-To: <20090601123503.2337a79b.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: cl@linux-foundation.org, linux-mm@kvack.org, pavel@ucw.cz, dave@linux.vnet.ibm.com
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
>> We really should have a machine readable channel for this sort of 
>> information, so it can be plumbed to a userspace notification bubble the 
>> user can ignore.
>>     
>
> That could just be printk().  It's a question of a) how to tell
> userspace which bits to pay attention to and maybe b) adding some
> more structure to the text.
>
> Perhaps careful use of faciliy levels would suffice for a), but I
> expect that some new tagging scheme would be more practical.
>   

I thought dmesg was an unreliable channel which can overflow.  It's also 
prone to attacks by spell checkers.

I prefer reliable binary interfaces to shell explorable text interfaces 
as I think any feature worth having is much more useful controlled by an 
application rather than a bored sysadmin.

-- 
I have a truly marvellous patch that fixes the bug which this
signature is too narrow to contain.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

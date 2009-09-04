Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 5A62C6B0089
	for <linux-mm@kvack.org>; Fri,  4 Sep 2009 12:17:00 -0400 (EDT)
Message-ID: <4AA13D0F.6050502@zytor.com>
Date: Fri, 04 Sep 2009 09:15:11 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [PATCH] x86: reuse the boot-time mappings of fixed_addresses
References: <4A90AADE.20307@gmail.com> <20090829110046.GA6812@elte.hu> <4A997088.60908@zytor.com> <20090831082632.GB15619@elte.hu> <4A9C6ADF.2020707@goop.org> <20090904073355.GA20598@elte.hu> <4AA1369A.5040204@goop.org>
In-Reply-To: <4AA1369A.5040204@goop.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: Ingo Molnar <mingo@elte.hu>, Xiao Guangrong <ericxiao.gr@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Rusty Russell <rusty@rustcorp.com.au>, Jens Axboe <jens.axboe@oracle.com>, Xiao Guangrong <xiaoguangrong@cn.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>
List-ID: <linux-mm.kvack.org>

On 09/04/2009 08:47 AM, Jeremy Fitzhardinge wrote:
> On 09/04/09 00:33, Ingo Molnar wrote:
>>> It hardly seems worth it, but I guess it isn't much code. [...]
>>>     
>> Ok, i understood this as an Acked-by from you - lemme know if that's 
>> wrong ;-)
>>   
> 
> That's a bit proactive.  It's more "Meh-I-suppose-d-by: ".
> 

Pretty much.  I suspect we'll have to undo this when we fix the fixmap,
since it will no longer be adjacent to the vmalloc range.

	-hpa

-- 
H. Peter Anvin, Intel Open Source Technology Center
I work for Intel.  I don't speak on their behalf.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

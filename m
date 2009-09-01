Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7EBC46B004D
	for <linux-mm@kvack.org>; Mon, 31 Aug 2009 20:29:27 -0400 (EDT)
Message-ID: <4A9C6ADF.2020707@goop.org>
Date: Mon, 31 Aug 2009 17:29:19 -0700
From: Jeremy Fitzhardinge <jeremy@goop.org>
MIME-Version: 1.0
Subject: Re: [PATCH] x86: reuse the boot-time mappings of fixed_addresses
References: <4A90AADE.20307@gmail.com> <20090829110046.GA6812@elte.hu> <4A997088.60908@zytor.com> <20090831082632.GB15619@elte.hu>
In-Reply-To: <20090831082632.GB15619@elte.hu>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Xiao Guangrong <ericxiao.gr@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Rusty Russell <rusty@rustcorp.com.au>, Jens Axboe <jens.axboe@oracle.com>, Xiao Guangrong <xiaoguangrong@cn.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>
List-ID: <linux-mm.kvack.org>

On 08/31/09 01:26, Ingo Molnar wrote:
>>> I'm wondering, how much space do we save this way, on a typical bootup 
>>> on a typical PC?
>>>
>>>       
>> Not a huge lot... a few dozen pages.
>>     
> I guess it's still worth doing - what do you think?
>   

It hardly seems worth it, but I guess it isn't much code.  Will having
an apparent overlap of vmalloc and fixmap spaces confuse anything?

    J

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

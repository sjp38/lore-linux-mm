Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 537646B0085
	for <linux-mm@kvack.org>; Fri,  4 Sep 2009 11:47:35 -0400 (EDT)
Message-ID: <4AA1369A.5040204@goop.org>
Date: Fri, 04 Sep 2009 08:47:38 -0700
From: Jeremy Fitzhardinge <jeremy@goop.org>
MIME-Version: 1.0
Subject: Re: [PATCH] x86: reuse the boot-time mappings of fixed_addresses
References: <4A90AADE.20307@gmail.com> <20090829110046.GA6812@elte.hu> <4A997088.60908@zytor.com> <20090831082632.GB15619@elte.hu> <4A9C6ADF.2020707@goop.org> <20090904073355.GA20598@elte.hu>
In-Reply-To: <20090904073355.GA20598@elte.hu>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Xiao Guangrong <ericxiao.gr@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Rusty Russell <rusty@rustcorp.com.au>, Jens Axboe <jens.axboe@oracle.com>, Xiao Guangrong <xiaoguangrong@cn.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>
List-ID: <linux-mm.kvack.org>

On 09/04/09 00:33, Ingo Molnar wrote:
>> It hardly seems worth it, but I guess it isn't much code. [...]
>>     
> Ok, i understood this as an Acked-by from you - lemme know if that's 
> wrong ;-)
>   

That's a bit proactive.  It's more "Meh-I-suppose-d-by: ".

    J

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

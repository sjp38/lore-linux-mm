Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 2B4E16B0085
	for <linux-mm@kvack.org>; Fri,  4 Sep 2009 14:55:41 -0400 (EDT)
Date: Fri, 4 Sep 2009 20:55:29 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH] x86: reuse the boot-time mappings of fixed_addresses
Message-ID: <20090904185529.GA1874@elte.hu>
References: <4A90AADE.20307@gmail.com> <20090829110046.GA6812@elte.hu> <4A997088.60908@zytor.com> <20090831082632.GB15619@elte.hu> <4A9C6ADF.2020707@goop.org> <20090904073355.GA20598@elte.hu> <4AA1369A.5040204@goop.org> <4AA13D0F.6050502@zytor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4AA13D0F.6050502@zytor.com>
Sender: owner-linux-mm@kvack.org
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Jeremy Fitzhardinge <jeremy@goop.org>, Xiao Guangrong <ericxiao.gr@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Rusty Russell <rusty@rustcorp.com.au>, Jens Axboe <jens.axboe@oracle.com>, Xiao Guangrong <xiaoguangrong@cn.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>
List-ID: <linux-mm.kvack.org>


* H. Peter Anvin <hpa@zytor.com> wrote:

> On 09/04/2009 08:47 AM, Jeremy Fitzhardinge wrote:
> > On 09/04/09 00:33, Ingo Molnar wrote:
> >>> It hardly seems worth it, but I guess it isn't much code. [...]
> >>>     
> >> Ok, i understood this as an Acked-by from you - lemme know if that's 
> >> wrong ;-)
> >>   
> > 
> > That's a bit proactive.  It's more "Meh-I-suppose-d-by: ".
> > 
> 
> Pretty much.  I suspect we'll have to undo this when we fix the 
> fixmap, since it will no longer be adjacent to the vmalloc range.

Ok, i've removed the patch from tip:x86/mm ...

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 4B13B6B004D
	for <linux-mm@kvack.org>; Fri,  1 Jun 2012 08:29:10 -0400 (EDT)
Received: by dakp5 with SMTP id p5so3486088dak.14
        for <linux-mm@kvack.org>; Fri, 01 Jun 2012 05:29:09 -0700 (PDT)
Date: Fri, 1 Jun 2012 21:28:52 +0900 (KST)
From: Joonsoo Kim <js1304@gmail.com>
Subject: Re: [PATCH 4/4] slub: refactoring unfreeze_partials()
In-Reply-To: <alpine.DEB.2.00.1205171329440.12366@router.home>
Message-ID: <alpine.DEB.2.02.1206012125520.3153@js1304-desktop>
References: <1337269668-4619-1-git-send-email-js1304@gmail.com> <1337269668-4619-5-git-send-email-js1304@gmail.com> <alpine.DEB.2.00.1205171329440.12366@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org



On Thu, 17 May 2012, Christoph Lameter wrote:

> On Fri, 18 May 2012, Joonsoo Kim wrote:
>
>> I think that these are disadvantages of current implementation,
>> so I do refactoring unfreeze_partials().
>
> The reason the current implementation is so complex is to avoid races. The
> state of the list and the state of the partial pages must be consistent at
> all times.
>
>> Minimizing code in do {} while loop introduce a reduced fail rate
>> of cmpxchg_double_slab. Below is output of 'slabinfo -r kmalloc-256'
>> when './perf stat -r 33 hackbench 50 process 4000 > /dev/null' is done.
>
> Looks good. If I can convince myself that this does not open up any
> new races then I may ack it.

This is a reminder mail.
Would u give me some comments for this please?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

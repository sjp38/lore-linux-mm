Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f172.google.com (mail-ob0-f172.google.com [209.85.214.172])
	by kanga.kvack.org (Postfix) with ESMTP id 44EFD6B006C
	for <linux-mm@kvack.org>; Fri, 20 Mar 2015 20:48:04 -0400 (EDT)
Received: by obbgg8 with SMTP id gg8so89487288obb.1
        for <linux-mm@kvack.org>; Fri, 20 Mar 2015 17:48:04 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id kg7si3211740obb.56.2015.03.20.17.48.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 20 Mar 2015 17:48:03 -0700 (PDT)
Message-ID: <550CBDB8.1090501@oracle.com>
Date: Fri, 20 Mar 2015 18:39:20 -0600
From: David Ahern <david.ahern@oracle.com>
MIME-Version: 1.0
Subject: Re: 4.0.0-rc4: panic in free_block
References: <550C37C9.2060200@oracle.com> <CA+55aFxoVPRuFJGuP_=0-NCiqx_NPeJBv+SAZqbAzeC9AhN+CA@mail.gmail.com> <550CA3F9.9040201@oracle.com> <550CB8D1.9030608@oracle.com> <alpine.DEB.2.10.1503201731560.22072@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.10.1503201731560.22072@chino.kir.corp.google.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 3/20/15 6:34 PM, David Rientjes wrote:
> On Fri, 20 Mar 2015, David Ahern wrote:
>
>> Here's another data point: If I disable NUMA I don't see the problem.
>> Performance drops, but no NULL pointer splats which would have been panics.
>>
>> The 128 cpu ldom with NUMA enabled shows the problem every single time I do a
>> kernel compile (-j 128). With NUMA disabled I have done 3 allyesconfig
>> compiles without hitting the problem. I'll put the compiles into a loop while
>> I head out for dinner.
>>
>
> It might be helpful to enable CONFIG_DEBUG_SLAB if you're reproducing it.
>

I enabled that and a few other DEBUG configs earlier -- nothing popped 
out. I'll do it again -- and others when I return.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

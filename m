Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f176.google.com (mail-ig0-f176.google.com [209.85.213.176])
	by kanga.kvack.org (Postfix) with ESMTP id B8DAE6B0038
	for <linux-mm@kvack.org>; Fri, 20 Mar 2015 20:34:46 -0400 (EDT)
Received: by igcau2 with SMTP id au2so1714334igc.0
        for <linux-mm@kvack.org>; Fri, 20 Mar 2015 17:34:46 -0700 (PDT)
Received: from mail-ig0-x22a.google.com (mail-ig0-x22a.google.com. [2607:f8b0:4001:c05::22a])
        by mx.google.com with ESMTPS id dr13si245524icb.24.2015.03.20.17.34.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Mar 2015 17:34:46 -0700 (PDT)
Received: by igcau2 with SMTP id au2so1328574igc.1
        for <linux-mm@kvack.org>; Fri, 20 Mar 2015 17:34:46 -0700 (PDT)
Date: Fri, 20 Mar 2015 17:34:44 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: 4.0.0-rc4: panic in free_block
In-Reply-To: <550CB8D1.9030608@oracle.com>
Message-ID: <alpine.DEB.2.10.1503201731560.22072@chino.kir.corp.google.com>
References: <550C37C9.2060200@oracle.com> <CA+55aFxoVPRuFJGuP_=0-NCiqx_NPeJBv+SAZqbAzeC9AhN+CA@mail.gmail.com> <550CA3F9.9040201@oracle.com> <550CB8D1.9030608@oracle.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Ahern <david.ahern@oracle.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, 20 Mar 2015, David Ahern wrote:

> Here's another data point: If I disable NUMA I don't see the problem.
> Performance drops, but no NULL pointer splats which would have been panics.
> 
> The 128 cpu ldom with NUMA enabled shows the problem every single time I do a
> kernel compile (-j 128). With NUMA disabled I have done 3 allyesconfig
> compiles without hitting the problem. I'll put the compiles into a loop while
> I head out for dinner.
> 

It might be helpful to enable CONFIG_DEBUG_SLAB if you're reproducing it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

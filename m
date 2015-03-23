Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f41.google.com (mail-yh0-f41.google.com [209.85.213.41])
	by kanga.kvack.org (Postfix) with ESMTP id 9A2CD6B0038
	for <linux-mm@kvack.org>; Mon, 23 Mar 2015 15:58:59 -0400 (EDT)
Received: by yhpt93 with SMTP id t93so74480845yhp.0
        for <linux-mm@kvack.org>; Mon, 23 Mar 2015 12:58:59 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id f188si829499ykd.88.2015.03.23.12.58.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 23 Mar 2015 12:58:58 -0700 (PDT)
Message-ID: <5510707A.2090509@oracle.com>
Date: Mon, 23 Mar 2015 13:58:50 -0600
From: David Ahern <david.ahern@oracle.com>
MIME-Version: 1.0
Subject: Re: 4.0.0-rc4: panic in free_block
References: <20150322.221906.1670737065885267482.davem@davemloft.net>	<20150323.122530.812870422534676208.davem@davemloft.net>	<55104EAA.4060607@oracle.com> <20150323.153537.1167433221134028872.davem@davemloft.net>
In-Reply-To: <20150323.153537.1167433221134028872.davem@davemloft.net>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>
Cc: torvalds@linux-foundation.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, bpicco@meloft.net

On 3/23/15 1:35 PM, David Miller wrote:
> From: David Ahern <david.ahern@oracle.com>
> Date: Mon, 23 Mar 2015 11:34:34 -0600
>
>> seems like a formality at this point, but this resolves the panic on
>> the M7-based ldom and baremetal. The T5-8 failed to boot, but it could
>> be a different problem.
>
> Specifically, does the T5-8 boot without my patch applied?
>

I am running around in circles with it... it takes 15 minutes after a 
hard reset to get logged in, and I forgot that the 2.6.39 can't handle 
-j 1024 either (task scheduler problem), and then I wasted time waiting 
for sandwich shop to learn how to use mobile app ordering, ...

I'll respond as soon as I can.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

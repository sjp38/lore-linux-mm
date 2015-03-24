Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f46.google.com (mail-qg0-f46.google.com [209.85.192.46])
	by kanga.kvack.org (Postfix) with ESMTP id D52CB6B0038
	for <linux-mm@kvack.org>; Mon, 23 Mar 2015 21:02:02 -0400 (EDT)
Received: by qgfa8 with SMTP id a8so174087446qgf.0
        for <linux-mm@kvack.org>; Mon, 23 Mar 2015 18:02:02 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id q85si2473811qkh.112.2015.03.23.18.02.01
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Mar 2015 18:02:02 -0700 (PDT)
Message-ID: <5510B783.4050809@oracle.com>
Date: Mon, 23 Mar 2015 19:01:55 -0600
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

The T5-8 is having problems; has to be unrelated to this commit. T5-2 
(256 cpus) boots fine, and make -j 256 on an allyesconfig builds fine.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

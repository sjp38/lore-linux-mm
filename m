Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f182.google.com (mail-yk0-f182.google.com [209.85.160.182])
	by kanga.kvack.org (Postfix) with ESMTP id D55FE6B0038
	for <linux-mm@kvack.org>; Fri, 20 Mar 2015 15:54:16 -0400 (EDT)
Received: by ykfc206 with SMTP id c206so47555143ykf.1
        for <linux-mm@kvack.org>; Fri, 20 Mar 2015 12:54:16 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id v43si2584137yhv.45.2015.03.20.12.54.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 20 Mar 2015 12:54:16 -0700 (PDT)
Message-ID: <550C7AE1.1000808@oracle.com>
Date: Fri, 20 Mar 2015 13:54:09 -0600
From: David Ahern <david.ahern@oracle.com>
MIME-Version: 1.0
Subject: Re: 4.0.0-rc4: panic in free_block
References: <550C5078.8040402@oracle.com>	<CA+55aFyQWa0PjT-3y-HB9P-UAzThrZme5gj1P6P6hMTTF9cMtA@mail.gmail.com>	<550C6151.8070803@oracle.com> <20150320.154700.1250039074828760104.davem@davemloft.net>
In-Reply-To: <20150320.154700.1250039074828760104.davem@davemloft.net>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>
Cc: torvalds@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org

On 3/20/15 1:47 PM, David Miller wrote:
> From: David Ahern <david.ahern@oracle.com>
> Date: Fri, 20 Mar 2015 12:05:05 -0600
>
>> DaveM: do you mind if I submit a patch to change the default for sparc
>> to SLUB?
>
> I think we're jumping the gun about all of this, and doing anything
> with default Kconfig settings would be entirely premature until we
> know what the real bug is.

The suggestion to change to SLUB as the default was based on Linus' 
comment "SLAB is probably also almost unheard of in high-CPU
configurations, since slub has all the magical unlocked lists etc for
scalability."

>
> On my T4-2 I've used nothing but SLAB and haven't hit any of these
> problems.  I can't even remember the last time I turned SLUB on,
> and it's just because I'm lazy.
>

Interesting. With -j <64 and talking softly it completes. But -j 128 and 
higher always ends in a panic.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

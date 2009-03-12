Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 269BE6B007E
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 07:48:53 -0400 (EDT)
Received: by bwz18 with SMTP id 18so376300bwz.38
        for <linux-mm@kvack.org>; Thu, 12 Mar 2009 04:48:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <e2dc2c680903120438i27e209c2h28c61704299b8b4f@mail.gmail.com>
References: <20090311114353.GA759@localhost>
	 <e2dc2c680903110516v2c66d4a4h6a422cffceb12e2@mail.gmail.com>
	 <20090311122611.GA8804@localhost>
	 <e2dc2c680903120053w37968c1cy556812cef63f0896@mail.gmail.com>
	 <20090312075952.GA19331@localhost>
	 <e2dc2c680903120104h4d19a3f6j57ad045bc06f9a90@mail.gmail.com>
	 <20090312081113.GA19506@localhost>
	 <e2dc2c680903120117j7be962b2xd63f3296f8f65a46@mail.gmail.com>
	 <20090312103847.GA20210@localhost>
	 <e2dc2c680903120438i27e209c2h28c61704299b8b4f@mail.gmail.com>
Date: Thu, 12 Mar 2009 12:48:50 +0100
Message-ID: <e2dc2c680903120448q386f84a4t5667e22751002ae9@mail.gmail.com>
Subject: Re: Memory usage per memory zone
From: jack marrow <jackmarrow2@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>> Sure, but something is unreclaimable... Maybe some process is taking a
>> lot of shared memory(shm)? What's the output of `lsof`?
>
> I can't paste that, but I expect oracle is using it.

Maybe this is helpful:

#  ipcs |grep oracle
0x00000000 2293770    oracle    640        4194304    22
0x00000000 2326539    oracle    640        536870912  22
0x880f3334 2359308    oracle    640        266338304  22
0x0f9b5efc 1933312    oracle    640        44

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

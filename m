Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f169.google.com (mail-ie0-f169.google.com [209.85.223.169])
	by kanga.kvack.org (Postfix) with ESMTP id EC9056B0032
	for <linux-mm@kvack.org>; Thu, 11 Jun 2015 17:56:28 -0400 (EDT)
Received: by iebmu5 with SMTP id mu5so13145500ieb.1
        for <linux-mm@kvack.org>; Thu, 11 Jun 2015 14:56:28 -0700 (PDT)
Received: from mail-ig0-x244.google.com (mail-ig0-x244.google.com. [2607:f8b0:4001:c05::244])
        by mx.google.com with ESMTPS id p65si1512542iop.13.2015.06.11.14.56.28
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Jun 2015 14:56:28 -0700 (PDT)
Received: by igdj8 with SMTP id j8so5084054igd.2
        for <linux-mm@kvack.org>; Thu, 11 Jun 2015 14:56:28 -0700 (PDT)
Message-ID: <1434059786.27504.58.camel@edumazet-glaptop2.roam.corp.google.com>
Subject: Re: [RFC] net: use atomic allocation for order-3 page allocation
From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 11 Jun 2015 14:56:26 -0700
In-Reply-To: <20150611214525.GA406740@devbig257.prn2.facebook.com>
References: 
	<71a20cf185c485fa23d9347bd846a6f4e9753405.1434053941.git.shli@fb.com>
	 <1434055687.27504.51.camel@edumazet-glaptop2.roam.corp.google.com>
	 <5579FABE.4050505@fb.com>
	 <1434057733.27504.52.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150611214525.GA406740@devbig257.prn2.facebook.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@fb.com>
Cc: Chris Mason <clm@fb.com>, netdev@vger.kernel.org, davem@davemloft.net, Kernel-team@fb.com, Eric Dumazet <edumazet@google.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org

On Thu, 2015-06-11 at 14:45 -0700, Shaohua Li wrote:

> This is exactly what the patch try to do. Atomic 32k allocation will
> fail with memory pressure, kswapd is waken up to do compaction and we
> fallback to 4k.

Read your changelog, then read what you just wrote.

Your changelog  said :

'compaction will not be triggered and we will fallback to order-0
immediately.'

Now you tell me that compaction is started.

What is the truth ?

Please make sure changelog is precise, this would avoid many mails.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

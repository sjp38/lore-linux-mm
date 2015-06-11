Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f43.google.com (mail-qg0-f43.google.com [209.85.192.43])
	by kanga.kvack.org (Postfix) with ESMTP id C02546B006C
	for <linux-mm@kvack.org>; Thu, 11 Jun 2015 18:01:26 -0400 (EDT)
Received: by qgf75 with SMTP id 75so6064933qgf.1
        for <linux-mm@kvack.org>; Thu, 11 Jun 2015 15:01:26 -0700 (PDT)
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id w53si498154qge.37.2015.06.11.15.01.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 11 Jun 2015 15:01:26 -0700 (PDT)
Date: Thu, 11 Jun 2015 15:01:15 -0700
From: Shaohua Li <shli@fb.com>
Subject: Re: [RFC] net: use atomic allocation for order-3 page allocation
Message-ID: <20150611220115.GA448912@devbig257.prn2.facebook.com>
References: <71a20cf185c485fa23d9347bd846a6f4e9753405.1434053941.git.shli@fb.com>
 <1434055687.27504.51.camel@edumazet-glaptop2.roam.corp.google.com>
 <5579FABE.4050505@fb.com>
 <1434057733.27504.52.camel@edumazet-glaptop2.roam.corp.google.com>
 <20150611214525.GA406740@devbig257.prn2.facebook.com>
 <1434059786.27504.58.camel@edumazet-glaptop2.roam.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <1434059786.27504.58.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Chris Mason <clm@fb.com>, netdev@vger.kernel.org, davem@davemloft.net, Kernel-team@fb.com, Eric Dumazet <edumazet@google.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org

On Thu, Jun 11, 2015 at 02:56:26PM -0700, Eric Dumazet wrote:
> On Thu, 2015-06-11 at 14:45 -0700, Shaohua Li wrote:
> 
> > This is exactly what the patch try to do. Atomic 32k allocation will
> > fail with memory pressure, kswapd is waken up to do compaction and we
> > fallback to 4k.
> 
> Read your changelog, then read what you just wrote.
> 
> Your changelog  said :
> 
> 'compaction will not be triggered and we will fallback to order-0
> immediately.'
> 
> Now you tell me that compaction is started.
> 
> What is the truth ?
> 
> Please make sure changelog is precise, this would avoid many mails.

Ah, ok. I mean direct compaction isn't triggered, kswapd is still waken
up to do compaction. I'll update the changelog.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

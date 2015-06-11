Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f176.google.com (mail-qk0-f176.google.com [209.85.220.176])
	by kanga.kvack.org (Postfix) with ESMTP id A0BE86B006C
	for <linux-mm@kvack.org>; Thu, 11 Jun 2015 18:18:05 -0400 (EDT)
Received: by qkhg32 with SMTP id g32so9157378qkh.0
        for <linux-mm@kvack.org>; Thu, 11 Jun 2015 15:18:05 -0700 (PDT)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2001:4f8:3:36:211:85ff:fe63:a549])
        by mx.google.com with ESMTP id 63si157699qhw.101.2015.06.11.15.18.04
        for <linux-mm@kvack.org>;
        Thu, 11 Jun 2015 15:18:04 -0700 (PDT)
Date: Thu, 11 Jun 2015 15:18:01 -0700 (PDT)
Message-Id: <20150611.151801.1297394068071005900.davem@davemloft.net>
Subject: Re: [RFC] net: use atomic allocation for order-3 page allocation
From: David Miller <davem@davemloft.net>
In-Reply-To: <CAATkVEw93KaUQuNJY9hxA+q2dxPb2AAxicojkjDfXDZU5VGxtg@mail.gmail.com>
References: <1434055687.27504.51.camel@edumazet-glaptop2.roam.corp.google.com>
	<5579FABE.4050505@fb.com>
	<CAATkVEw93KaUQuNJY9hxA+q2dxPb2AAxicojkjDfXDZU5VGxtg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dbavatar@gmail.com
Cc: clm@fb.com, eric.dumazet@gmail.com, shli@fb.com, netdev@vger.kernel.org, Kernel-team@fb.com, edumazet@google.com, rientjes@google.com, linux-mm@kvack.org, johunt@akamai.com, dbanerje@akamai.com


Please stop top-posting.

Quote the relevant material you are replying to first, the add your
response commentary afterwards rather than beforehand.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 2DE6C900086
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 06:27:51 -0400 (EDT)
Received: by wwi36 with SMTP id 36so1556190wwi.26
        for <linux-mm@kvack.org>; Thu, 14 Apr 2011 03:27:49 -0700 (PDT)
Subject: Re: Regression from 2.6.36
From: Eric Dumazet <eric.dumazet@gmail.com>
In-Reply-To: <20110414110816.EA841944@pobox.sk>
References: <20110315132527.130FB80018F1@mail1005.cent>
	 <20110317001519.GB18911@kroah.com> <20110407120112.E08DCA03@pobox.sk>
	 <4D9D8FAA.9080405@suse.cz>
	 <BANLkTinnTnjZvQ9S1AmudZcZBokMy8-93w@mail.gmail.com>
	 <1302177428.3357.25.camel@edumazet-laptop>
	 <1302178426.3357.34.camel@edumazet-laptop>
	 <BANLkTikxWy-Pw1PrcAJMHs2R7JKksyQzMQ@mail.gmail.com>
	 <1302190586.3357.45.camel@edumazet-laptop>
	 <20110412154906.70829d60.akpm@linux-foundation.org>
	 <BANLkTincoaxp5Soe6O-eb8LWpgra=k2NsQ@mail.gmail.com>
	 <20110412183132.a854bffc.akpm@linux-foundation.org>
	 <1302662256.2811.27.camel@edumazet-laptop>
	 <20110413141600.28793661.akpm@linux-foundation.org>
	 <1302747058.3549.7.camel@edumazet-laptop>
	 <20110413222803.38e42baf.akpm@linux-foundation.org>
	 <1302762718.3549.229.camel@edumazet-laptop>
	 <20110414110816.EA841944@pobox.sk>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 14 Apr 2011 12:27:45 +0200
Message-ID: <1302776866.3248.2.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: azurIt <azurit@pobox.sk>
Cc: Andrew Morton <akpm@linux-foundation.org>, Changli Gao <xiaosuo@gmail.com>, =?ISO-8859-1?Q?Am=E9rico?= Wang <xiyou.wangcong@gmail.com>, Jiri Slaby <jslaby@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Jiri Slaby <jirislaby@gmail.com>, Mel Gorman <mel@csn.ul.ie>

Le jeudi 14 avril 2011 A  11:08 +0200, azurIt a A(C)crit :
> Here it is:
> 
> 
> # ls /proc/31416/fd | wc -l
> 5926

Hmm, if its a 32bit kernel, I am afraid Andrew patch wont solve the
problem...

[On 32bit kernel, we still use kmalloc() up to 8192 files ]


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

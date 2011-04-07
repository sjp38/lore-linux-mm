Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 200DC8D003B
	for <linux-mm@kvack.org>; Thu,  7 Apr 2011 11:36:33 -0400 (EDT)
Received: by wwi18 with SMTP id 18so5183057wwi.2
        for <linux-mm@kvack.org>; Thu, 07 Apr 2011 08:36:30 -0700 (PDT)
Subject: Re: Regression from 2.6.36
From: Eric Dumazet <eric.dumazet@gmail.com>
In-Reply-To: <BANLkTikxWy-Pw1PrcAJMHs2R7JKksyQzMQ@mail.gmail.com>
References: <20110315132527.130FB80018F1@mail1005.cent>
	 <20110317001519.GB18911@kroah.com> <20110407120112.E08DCA03@pobox.sk>
	 <4D9D8FAA.9080405@suse.cz>
	 <BANLkTinnTnjZvQ9S1AmudZcZBokMy8-93w@mail.gmail.com>
	 <1302177428.3357.25.camel@edumazet-laptop>
	 <1302178426.3357.34.camel@edumazet-laptop>
	 <BANLkTikxWy-Pw1PrcAJMHs2R7JKksyQzMQ@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 07 Apr 2011 17:36:26 +0200
Message-ID: <1302190586.3357.45.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Changli Gao <xiaosuo@gmail.com>
Cc: =?ISO-8859-1?Q?Am=E9rico?= Wang <xiyou.wangcong@gmail.com>, Jiri Slaby <jslaby@suse.cz>, azurIt <azurit@pobox.sk>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Jiri Slaby <jirislaby@gmail.com>

Le jeudi 07 avril 2011 A  23:27 +0800, Changli Gao a A(C)crit :

> azurlt, would you please test the patch attached? Thanks.
> 

Yes of course, I meant to reverse the patch

(use kmalloc() under PAGE_SIZE, vmalloc() for 'big' allocs)


Dont fallback to vmalloc if kmalloc() fails.


if (size <= PAGE_SIZE)
	return kmalloc(size, GFP_KERNEL);
else
	return vmalloc(size);



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

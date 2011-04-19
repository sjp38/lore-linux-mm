Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id A57CF8D003B
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 15:56:55 -0400 (EDT)
Date: Tue, 19 Apr 2011 12:55:57 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: Regression from 2.6.36
Message-Id: <20110419125557.b381e097.akpm@linux-foundation.org>
In-Reply-To: <20110419212920.AFE7DD8D@pobox.sk>
References: <20110315132527.130FB80018F1@mail1005.cent>
	<20110317001519.GB18911@kroah.com>
	<20110407120112.E08DCA03@pobox.sk>
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
	<20110413142416.507e3ed0.akpm@linux-foundation.org>
	<20110419212920.AFE7DD8D@pobox.sk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: azurIt <azurit@pobox.sk>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Changli Gao <xiaosuo@gmail.com>, =?ISO-8859-1?Q? Am=E9rico_Wang ?= <xiyou.wangcong@gmail.com>, Jiri Slaby <jslaby@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Jiri Slaby <jirislaby@gmail.com>, Mel Gorman <mel@csn.ul.ie>

On Tue, 19 Apr 2011 21:29:20 +0200
"azurIt" <azurit@pobox.sk> wrote:

> which kernel versions will include this patch ? Thank you.

Probably 2.6.39. If so, some later 2.6.38.x too.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

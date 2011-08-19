Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 752656B0169
	for <linux-mm@kvack.org>; Fri, 19 Aug 2011 16:48:05 -0400 (EDT)
Received: by eyh6 with SMTP id 6so2170834eyh.20
        for <linux-mm@kvack.org>; Fri, 19 Aug 2011 13:48:02 -0700 (PDT)
MIME-Version: 1.0
Date: Sat, 20 Aug 2011 02:11:53 +0530
Message-ID: <CAOn_VZYLOG9ctDomhMzyk19jVeKWWMvftvjyXRwfCyNn+4jinA@mail.gmail.com>
Subject: what protects page lru list?
From: Rajesh Ghanekar <rajeshsg@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

Hi,
   I am confused with what protects page->lru? Is it both zone->lru_lock or
zone->lock? I can see it being protected either by lru_lock or lock.
Are their any
rules where to use lru_lock and where to use lock?

   I did google but couldn't find anything. Sorry if its already discusses
elsewhere, but I couldn't locate any.

- Rajesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

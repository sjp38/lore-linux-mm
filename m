Received: by fenrus.demon.nl
	via sendmail from stdin
	id <m13d8p5-000OWvC@amadeus.home.nl> (Debian Smail3.2.0.102)
	for linux-mm@kvack.org; Sun, 24 Sep 2000 12:15:51 +0200 (CEST)
Message-Id: <m13d8p5-000OWvC@amadeus.home.nl>
Date: Sun, 24 Sep 2000 12:15:51 +0200 (CEST)
From: root@fenrus.demon.nl (Arjan van de Ven)
Subject: Re: refill_inactive()
In-Reply-To: <Pine.LNX.4.21.0009241148100.2789-100000@elte.hu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: mingo@elte.hu
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

In article <Pine.LNX.4.21.0009241148100.2789-100000@elte.hu> you wrote:
> i'm wondering about the following piece of code in refill_inactive():

>                 if (current->need_resched && (gfp_mask & __GFP_IO)) {
>                         __set_current_state(TASK_RUNNING);
>                         schedule();
>                 }

> shouldnt this be __GFP_WAIT? It's true that __GFP_IO implies __GFP_WAIT
> (because IO cannot be done without potentially scheduling), so the code is

Is this also true for starting IO ?

Greetings,
   Arjan van de Ven
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

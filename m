Received: by fenrus.demon.nl
	via sendmail from stdin
	id <m12jdKA-000OVtC@amadeus.home.nl> (Debian Smail3.2.0.102)
	for linux-mm@kvack.org; Mon, 24 Apr 2000 09:30:30 +0200 (CEST)
Message-Id: <m12jdKA-000OVtC@amadeus.home.nl>
Date: Mon, 24 Apr 2000 09:30:30 +0200 (CEST)
From: arjan@fenrus.demon.nl (Arjan van de Ven)
Subject: Re: [patch] memory hog protection
In-Reply-To: <Pine.LNX.4.21.0004232255530.1852-100000@duckman.conectiva> <3903D353.D98969B7@mandrakesoft.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeff Garzik <jgarzik@mandrakesoft.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

In article <3903D353.D98969B7@mandrakesoft.com> you wrote:
>> the patch below changes the mm->swap_cnt assignment to put
>> memory hogs at a disadvantage to programs with a smaller

> There are many classes of problems where preserving interactivity at the
> expense of a resource hog is a bad not good idea.  Think of obscure
> situations like database servers for example :)

Is it really that bad to have a sysctl (or other /proc thingy) named
"boostinteractive" or whatever, and means that the owner of the machine
wants to favor interactive processes over memory/cpu hogs.
This can be used for
1) Rick's MM pressure stuff
2) The scheduler 
3) The OOM selection algorithm

Greetings,
    Arjan van de Ven
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

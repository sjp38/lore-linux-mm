Received: from i48.dragon.cz (i48.dragon.cz [212.71.161.50])
	by web.dragon.cz (8.11.3/8.11.1/ms.dragon.cz) with ESMTP id f3JK7N714996
	for <linux-mm@kvack.org>; Thu, 19 Apr 2001 22:07:24 +0200
Date: Mon, 19 Mar 2001 21:06:55 +0100
From: happz <happz@dragon.cz>
Reply-To: happz <happz@dragon.cz>
Message-ID: <1809062307.20010319210655@dragon.cz>
Subject: Re: suspend processes at load
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

What about this: give to process way how to tell kernel "it is not
good to suspend me, because there are process' that depend on me and
wouldn't be blocked." Syscall or /proc filesystem could be used.

It is not the way how to say which process should be suspended but a
way how to say which could NOT - usefull for example for X server, may
be some daemons, aso.

Milos Prchlik


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

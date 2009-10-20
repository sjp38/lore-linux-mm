Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 0615C6B004F
	for <linux-mm@kvack.org>; Tue, 20 Oct 2009 15:17:07 -0400 (EDT)
Received: from ultimate100.geggus.net ([2a01:198:297:1::1])
	by nerdhammel.gnuher.de (envelope-from
	<lists@fuchsschwanzdomain.de>)
	with esmtpsa (TLS1.0:RSA_AES_256_CBC_SHA1:32)
	(Exim 4.69)
	id 1N0KCc-0008H2-RM
	for linux-mm@kvack.org; Tue, 20 Oct 2009 21:17:02 +0200
Date: Tue, 20 Oct 2009 21:16:57 +0200
From: Sven Geggus <lists@fuchsschwanzdomain.de>
Subject: Re: Kernel crash on 2.6.31.x (kcryptd: page allocation failure..)
Message-ID: <20091020191656.GA11718@geggus.net>
References: <hbd4dk$5ac$1@ultimate100.geggus.net> <200910172230.13162.elendil@planet.nl> <hbd9v8$7rf$1@ultimate100.geggus.net> <200910190141.50752.elendil@planet.nl>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <200910190141.50752.elendil@planet.nl>
Sender: owner-linux-mm@kvack.org
To: Frans Pop <elendil@planet.nl>
Cc: linux-kernel@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, Kernel Testers List <kernel-testers@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Frans Pop schrieb am Montag, den 19. Oktober um 01:41 Uhr:

> In the mean time I've been able to trace the culprit. Could you please try 
> if reverting 373c0a7e + 8aa7e847 [1] on top of 2.6.31 fixes the issue for 
> you?

Unfortunately not :(

Starting from 2.6.31.4 I did
git revert 373c0a7e
git revert 8aa7e847 and build a new kernel.

The problem persists. The Kernel crashed again, this
time in "swapper".

Regards

Sven

-- 
"I'm a bastard, and proud of it"
                          (Linus Torvalds, Wednesday Sep 6, 2000)

/me is giggls@ircnet, http://sven.gegg.us/ on the Web

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

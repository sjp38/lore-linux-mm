Received: from atlas.CARNet.hr (zcalusic@atlas.CARNet.hr [161.53.123.163])
	by kvack.org (8.8.7/8.8.7) with ESMTP id RAA32083
	for <linux-mm@kvack.org>; Thu, 7 Jan 1999 17:31:19 -0500
Subject: Yet another MM problem (kswapd-zombie)
Reply-To: Zlatko.Calusic@CARNet.hr
MIME-Version: 1.0
From: Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
Date: 07 Jan 1999 23:31:11 +0100
Message-ID: <87iueiww9c.fsf@atlas.CARNet.hr>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I almost forgot, there is yet another big problem with changes on
kswapd (in pre5). Now, that kswapd is killable, in fact it only
becomes zombie, when SIGKILL is sent to it.

And not only that. If I run 'init 1' to go temporary to single user
mode, killall script zombifies kswapd (without asking me). If I later
return to multiuser level (plain ctrl-D), kswapd cannot be started
again. Or at least I didn't come up with a solution. I think that is
bad thing to happen.

If kswapd has to be killable (is it really necessary?), than we should
not lost it by simple changing runlevels (people do that, trust me).

Any clues?
-- 
Zlatko
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org

Date: Thu, 4 May 2000 20:04:09 -0700
Message-Id: <200005050304.UAA03317@pizda.ninka.net>
From: "David S. Miller" <davem@redhat.com>
In-reply-to: <Pine.LNX.4.21.0005050137120.8057-100000@alpha.random> (message
	from Andrea Arcangeli on Fri, 5 May 2000 01:44:23 +0200 (CEST))
Subject: Re: classzone-VM + mapped pages out of lru_cache
References: <Pine.LNX.4.21.0005050137120.8057-100000@alpha.random>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: andrea@suse.de
Cc: shrybman@sympatico.ca, quintela@fi.udc.es, gandalf@wlug.westbo.se, joerg.stroettchen@arcormail.de, linux-kernel@vger.rutgers.edu, axboe@suse.de, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrea, please do not pass IRQ state "flags" to another function
and try to restore them in this way, it breaks Sparc and any other
cpu which keeps "stack frame" state in the flags value.  "flags" must
be obtained and restored in the same function.

You do this in your rmqueue() changes.

Thanks.

Later,
David S. Miller
davem@redhat.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

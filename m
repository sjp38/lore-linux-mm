Date: Fri, 5 May 2000 16:56:11 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: classzone-VM + mapped pages out of lru_cache
In-Reply-To: <200005050304.UAA03317@pizda.ninka.net>
Message-ID: <Pine.LNX.4.21.0005051654300.207-100000@alpha.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "David S. Miller" <davem@redhat.com>
Cc: shrybman@sympatico.ca, quintela@fi.udc.es, gandalf@wlug.westbo.se, joerg.stroettchen@arcormail.de, linux-kernel@vger.rutgers.edu, axboe@suse.de, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 4 May 2000, David S. Miller wrote:

>Andrea, please do not pass IRQ state "flags" to another function
>and try to restore them in this way, it breaks Sparc and any other
>cpu which keeps "stack frame" state in the flags value.  "flags" must
>be obtained and restored in the same function.

Ok, thanks. Probably it worth to add a comment about this also in
reschedule_idle.

Fix is the same as in reschedule_idle, make rmqueue inline.

Thanks.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

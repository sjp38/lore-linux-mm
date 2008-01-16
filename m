Date: Wed, 16 Jan 2008 10:57:16 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 3/5] add /dev/mem_notify device
In-Reply-To: <20080115221627.GC1565@elf.ucw.cz>
References: <20080115100029.1178.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20080115221627.GC1565@elf.ucw.cz>
Message-Id: <20080116105102.11B1.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pavel Machek <pavel@ucw.cz>, Marcelo Tosatti <marcelo@kvack.org>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Daniel Spang <daniel.spang@gmail.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi Pavel

> > 	err = poll(&pollfds, 1, -1); // wake up at low memory
> > 
> >         ...
> > </usage example>
> 
> Nice, this is really needed for openmoko, zaurus, etc....
> 
> But this changelog needs to go into Documentation/...
> 
> ...and /dev/mem_notify is really a bad name. /dev/memory_low?
> /dev/oom?

thank you for your kindful advise.

but..

to be honest, my english is very limited.
I can't make judgments name is good or not.

Marcelo, What do you think his idea?




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Date: Tue, 15 Jan 2008 23:16:27 +0100
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [RFC][PATCH 3/5] add /dev/mem_notify device
Message-ID: <20080115221627.GC1565@elf.ucw.cz>
References: <20080115092828.116F.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20080115100029.1178.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080115100029.1178.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Marcelo Tosatti <marcelo@kvack.org>, Daniel Spang <daniel.spang@gmail.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi!

> the core of this patch series.
> add /dev/mem_notify device for notification low memory to user process.
> 
> <usage examle>
> 
>         fd = open("/dev/mem_notify", O_RDONLY);
>         if (fd < 0) {
>                 exit(1);
>         }
>         pollfds.fd = fd;
>         pollfds.events = POLLIN;
>         pollfds.revents = 0;
> 	err = poll(&pollfds, 1, -1); // wake up at low memory
> 
>         ...
> </usage example>

Nice, this is really needed for openmoko, zaurus, etc....

But this changelog needs to go into Documentation/...

...and /dev/mem_notify is really a bad name. /dev/memory_low?
/dev/oom?

									Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

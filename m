Date: Thu, 16 May 2002 11:51:03 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [RFC][PATCH] iowait statistics
In-Reply-To: <51039.193.133.92.239.1021542563.squirrel@lbbrown.homeip.net>
Message-ID: <Pine.LNX.4.44L.0205161149180.32261-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Leigh Brown <leigh@solinno.co.uk>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 16 May 2002, Leigh Brown wrote:

> I've tried this patch against Red Hat's 2.4.18 kernel on my laptop, and
> patched top to display the results.  It certainly seems to be working
> correctly running a few little contrived tests.

Cool, could you please post the patch to top so other people
can enjoy it too ? ;)

(I'm leaving for holidays this evening and am too lazy to patch
top myself now ;))

> CPU states: 0.5% user,  3.5% system,  0.0% nice,  0.0% idle, 95.8% wait
>
> which is what I'd expect based on my experience.    However, Doing a
> "raw /dev/raw/raw1 /dev/hdc" followed by a "dd if=/dev/raw/raw1 ..."
> gives this sort of result:
>
> CPU states: 0.3% user,  8.9% system,  0.0% nice, 77.2% idle, 13.3% wait
>
> I'm not sure if that can be explained by the way the raw I/O stuff works,
> or because I'm running it against 2.4.  Anyway, overall it's looking good.

Most likely the patch forgets to increment nr_iowait_tasks in
some raw IO code path...

regards,

Rik
-- 
Bravely reimplemented by the knights who say "NIH".

http://www.surriel.com/		http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

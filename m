Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 987106B002C
	for <linux-mm@kvack.org>; Tue,  7 Feb 2012 12:23:17 -0500 (EST)
Received: by wera13 with SMTP id a13so6988087wer.14
        for <linux-mm@kvack.org>; Tue, 07 Feb 2012 09:23:15 -0800 (PST)
MIME-Version: 1.0
Date: Tue, 7 Feb 2012 09:23:15 -0800
Message-ID: <CACBanvqb2VnVeHC33wZdE5OY61LgC_NiptmaCVvjn4fKEXaByw@mail.gmail.com>
Subject: [ATTEND] Linux Storage, FS & MM Summit 2012: Memory management
 challenges for embedded systems
From: Mandeep Singh Baines <msb@chromium.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf-pc@lists.linux-foundation.org
Cc: Luigi Semenzato <semenzato@chromium.org>, linux-mm@kvack.org, Olof Johansson <olofj@chromium.org>

Hi,

Please pardon the late submission.

I'd like to propose "Memory management challenges for embedded
systems" as an agenda topic for the Linux Storage, Filesystem, and
Multimedia Summit in San Francisco.

I am a kernel developer on the ChromiumOS project. I work on a number
of different areas of the kernel but memory management is definitely a
key focus area for our team and myself.

ChromiumOS much like a typical embedded system in that the resources
are constrained and the entire system is tuned for one application: in
our case, the browser.

>From an MM perspective, we've avoided using memory containment since
there is just a single application. For security, we avoid swap (no
unencrypted user data on persistent store). We also avoid swap because
of the variability it adds to latency. Since we don't have swap,
running out of memory is a constant challenge. We don't mind OOMing
but prefer it would happen quickly to avoid thrashing. We've used a
tiny hack in order to make this happen:

http://lwn.net/Articles/412313/

The hack requires us to predict working set size, it would be nice if
the kernel automatically calculated it. It would be nice if vmscan's
active and inactive list modeled the real working set. We have some
ideas on how to do that:

https://lkml.org/lkml/2010/11/3/394

Or perhaps it would be preferable to avoid OOM and instead let
user-space take some action:

http://lwn.net/Articles/475791/

But letting userspace take action on behalf of the kernel is always
tricky so maybe it would be better have something like tmem in
userspace:

http://lwn.net/Articles/468896/
http://lwn.net/Articles/340080/

Regards,
Mandeep

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Date: Mon, 30 Aug 1999 15:18:40 -0400 (EDT)
From: James Simmons <jsimmons@edgeglobal.com>
Subject: Re: accel handling
In-Reply-To: <m1aer9je4i.fsf@alogconduit1ae.ccr.net>
Message-ID: <Pine.LNX.4.10.9908301507530.5887-100000@imperial.edgeglobal.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Eric W. Biederman" <ebiederm+eric@ccr.net>
Cc: Marcus Sundberg <erammsu@kieraypc01.p.y.ki.era.ericsson.se>, "Stephen C. Tweedie" <sct@redhat.com>, linux-mm@kvack.org, ggi-develop <ggi-develop@eskimo.com>, FrameBuffer List <linux-fbdev@vuser.vu.union.edu>
List-ID: <linux-mm.kvack.org>

> C) We could simply put all processes that have the frame buffer
>    mapped to sleep during the interval that the accel enginge runs.

That it!!!! You gave me a idea. I just realize I have been thinking about
it all wrong. Its not looking at if the framebuffer is being accessed but
to keep track of all the processes that have mmap the framebuffer device.
When the accel engine is ready to go we put all the processes that have
/dev/fb mmapped to sleep no matter if its being access or not. One thing
that I would have to make sure that the same process thats being put to
sleep isn't also the one trying to use the accel engine.   

> F) It might be work bouncing this off of the ggi guys to see if they have
>    satisfactorily solved this problem.  Last I looked the ggi list was linux-ggi@eskimo.com

I'm one of those guys as well as a kernel developer.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/

Date: Mon, 30 Aug 1999 10:31:27 -0400 (EDT)
From: James Simmons <jsimmons@edgeglobal.com>
Subject: Re: accel handling
In-Reply-To: <37CA73D8.E41F4F5@switchboard.ericsson.se>
Message-ID: <Pine.LNX.4.10.9908300949550.3356-100000@imperial.edgeglobal.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcus Sundberg <erammsu@kieraypc01.p.y.ki.era.ericsson.se>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> What I believe James is talking about here is allowing non-priviledged
> processes to access graphics hardware where the graphics card, or even
> the whole system, may enter an unrecoverable state if you try to access
> the frame buffer while the accel engine is active. (Yes there really
> exist such hardware...)
> 
> To achieve this you really must physicly prevent the process to access
> the framebuffer while the accel engine is active. The question is what
> the best way to do this is (and if that way is good enough to bother
> doing it...) ?

Marcus you are on this list too. Actually I have though about what he
said. I never though of it this way but you can think of the accel engine
as another "process" trying to use the framebuffer. Their still is the
question. How do you know when a mmap of the framebuffer is being
accessed? So I can lock the accel engine when needed.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/

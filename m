Date: Fri, 29 Oct 1999 10:52:57 -0400 (EDT)
From: James Simmons <jsimmons@edgeglobal.com>
Subject: Re: page faults
In-Reply-To: <19991026110558.A1588@uni-koblenz.de>
Message-ID: <Pine.LNX.4.10.9910291049300.17696-100000@imperial.edgeglobal.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ralf Baechle <ralf@uni-koblenz.de>
Cc: "Eric W. Biederman" <ebiederm+eric@ccr.net>, "Stephen C. Tweedie" <sct@redhat.com>, "Benjamin C.R. LaHaise" <blah@kvack.org>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> In the past Linus already said that he doesn't want such a feature to
> enter mm and I agree with him because of the involved complexity.  So
> in short I'd say it's best to leave the operation of this interface
> undefined and recommend the usage of a separate rendering thread or
> a suitable mutual exclusion algorithem.

I agree too. I will see which is better. A mutal exclusion algorithm or a
special graphics thread which does have its own private mappings.

> > If the hardware cannot support two processors hitting the region
> > simultaneously, (support would be worst case the graphics would look
> > strange) you could have problems.
> 
> I'm sure there is stupid hardware which will allow to crash the system.

Its about proper virtualization. Imagine if userland would have to
negotate access to hard drives. 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/

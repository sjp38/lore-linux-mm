Received: from localhost (hahn@localhost)
	by coffee.psychology.mcmaster.ca (8.9.3/8.9.3) with ESMTP id SAA05911
	for <linux-mm@kvack.org>; Thu, 26 Oct 2000 18:33:26 -0400
Date: Thu, 26 Oct 2000 18:33:26 -0400 (EDT)
From: Mark Hahn <hahn@coffee.psychology.mcmaster.ca>
Subject: Re: Discussion on my OOM killer API
In-Reply-To: <Pine.LNX.4.21.0010261857580.15696-100000@duckman.distro.conectiva>
Message-ID: <Pine.LNX.4.10.10010261823300.5762-100000@coffee.psychology.mcmaster.ca>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> from a number of people who would like to have the OOM killer
> do something "special" for their system.

if they are few and/or special enough, it makes a lot more sense
for them to just maintain a private patch.  actually, I've never
seen a discussion of why such needs couldn't be served by a "god" 
process that mlocks itself, runs at RT, etc.  there are some minor
details to work out (does it poll, or get some hook?)

> For instance, they want to have student programs killed before
> staff programs, or want to be able to specify some priveledged
> processes that will never be killed (or do other things that

which could all be accomplished by providing a simple priority:
even 8 bits of ordering would probably be overkill...

regards, mark hahn

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

Date: Mon, 9 Oct 2000 19:37:57 +0200 (CEST)
From: Ingo Molnar <mingo@elte.hu>
Reply-To: mingo@elte.hu
Subject: Re: [PATCH] VM fix for 2.4.0-test9 & OOM handler
In-Reply-To: <Pine.LNX.4.10.10010091319360.29405-100000@coffee.psychology.mcmaster.ca>
Message-ID: <Pine.LNX.4.21.0010091936150.4393-100000@elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mark Hahn <hahn@coffee.psychology.mcmaster.ca>
Cc: Marco Colombo <marco@esi.it>, Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 9 Oct 2000, Mark Hahn wrote:

> > feature. Rather introduce a orthogonal voluntary "importance" system-call,
> > which marks processes as more and less important. This is similar to
> > priority, it can only be decreased by ordinary users.
> 
> nice!  call it CAP_IMPORTANT ;)
> come to think of it, I'm not sure more than one bit would be terribly
> useful - no any sane person is going to spend time 
> sorting all their processes by importance...

well, this is like priorities, there is a default value, and i suspect
root-owned daemons such as sendmail should get a higher 'importance'
rating. This is not really directed towards ordinary users, it's rather
for the protection of system-critical daemons. Anyway, this pushes the
policy into user-space.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

Date: Mon, 9 Oct 2000 13:25:53 -0400 (EDT)
From: Mark Hahn <hahn@coffee.psychology.mcmaster.ca>
Subject: Re: [PATCH] VM fix for 2.4.0-test9 & OOM handler
In-Reply-To: <Pine.LNX.4.21.0010091924450.3828-100000@elte.hu>
Message-ID: <Pine.LNX.4.10.10010091319360.29405-100000@coffee.psychology.mcmaster.ca>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Marco Colombo <marco@esi.it>, Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> feature. Rather introduce a orthogonal voluntary "importance" system-call,
> which marks processes as more and less important. This is similar to
> priority, it can only be decreased by ordinary users.

nice!  call it CAP_IMPORTANT ;)
come to think of it, I'm not sure more than one bit would be terribly
useful - no any sane person is going to spend time 
sorting all their processes by importance...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

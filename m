Date: Mon, 9 Oct 2000 19:27:11 +0200 (CEST)
From: Ingo Molnar <mingo@elte.hu>
Reply-To: mingo@elte.hu
Subject: Re: [PATCH] VM fix for 2.4.0-test9 & OOM handler
In-Reply-To: <Pine.LNX.4.21.0010091159430.20087-100000@Megathlon.ESI>
Message-ID: <Pine.LNX.4.21.0010091924450.3828-100000@elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marco Colombo <marco@esi.it>
Cc: Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 9 Oct 2000, Marco Colombo wrote:

> [...]
> > They are niced because the user thinks them a bit less
> > important. 
> 
> Please don't, this assumption is quite wrong. I use nice just to be
> 'nice' to other users. I can run my *important* CPU hog simulation
> nice +10 in order to let other people get more CPU when the need it.

yep. The OOM killer heuristics *must not* penalize any other kernel
feature. Rather introduce a orthogonal voluntary "importance" system-call,
which marks processes as more and less important. This is similar to
priority, it can only be decreased by ordinary users.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

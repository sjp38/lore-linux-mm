Date: Mon, 9 Oct 2000 20:01:48 +0200 (CEST)
From: Ingo Molnar <mingo@elte.hu>
Reply-To: mingo@elte.hu
Subject: Re: [PATCH] VM fix for 2.4.0-test9 & OOM handler
In-Reply-To: <00100913472801.03825@oscar>
Message-ID: <Pine.LNX.4.21.0010091959320.5031-100000@elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ed Tomlinson <tomlins@cam.org>
Cc: Mark Hahn <hahn@coffee.psychology.mcmaster.ca>, Marco Colombo <marco@esi.it>, Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 9 Oct 2000, Ed Tomlinson wrote:

> What about the AIX way?  When the system is nearly OOM it sends a
> SIG_DANGER signal to all processes.  Those that handle the signal are
> not initial targets for OOM...  Also in the SIG_DANGER processing they
> can take there own actions to reduce their memory usage... (we would
> have to look out for a SIG_DANGER handler that had a memory leak
> though)

i think 'importance' should be an integer value, not just a 'can it handle
SIG_DANGER' flag.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

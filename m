Received: from burns.conectiva (burns.conectiva [10.0.0.4])
	by perninha.conectiva.com.br (Postfix) with SMTP id 3620048108
	for <linux-mm@kvack.org>; Tue,  3 Dec 2002 18:57:04 -0200 (BRST)
Date: Tue, 3 Dec 2002 18:56:54 -0200 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] 2.4.20-rmap15a
In-Reply-To: <30200000.1038946087@titus>
Message-ID: <Pine.LNX.4.50L.0212031855590.22252-100000@duckman.distro.conectiva>
References: <Pine.LNX.4.44L.0212011833310.15981-100000@imladris.surriel.com>
 <6usmxfys45.fsf@zork.zork.net> <20021203195854.GA6709@zork.net>
 <30200000.1038946087@titus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: The One True Dave Barry <dave@zork.net>, linux-mm@kvack.org, sneakums@zork.net
List-ID: <linux-mm.kvack.org>

On Tue, 3 Dec 2002, Martin J. Bligh wrote:

> Assuming the extra time is eaten in Sys, not User,

It's not. It's idle time.  Looks like something very strange
is going on, vmstat and top output would be nice to have...

Rik
-- 
A: No.
Q: Should I include quotations after my reply?

http://www.surriel.com/		http://distro.conectiva.com/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

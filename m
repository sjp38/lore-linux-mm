Received: from burns.conectiva (burns.conectiva [10.0.0.4])
	by perninha.conectiva.com.br (Postfix) with SMTP id A866D38CF1
	for <linux-mm@kvack.org>; Wed, 22 Aug 2001 14:01:18 -0300 (EST)
Date: Wed, 22 Aug 2001 14:01:10 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] __alloc_pages_limit pages_min
In-Reply-To: <200108221519.f7MFJOR19243@maila.telia.com>
Message-ID: <Pine.LNX.4.33L.0108221400290.31410-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Roger Larsson <roger.larsson@norran.net>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 22 Aug 2001, Roger Larsson wrote:

> Note: reclaim_page will fix this situation direct it is allowed to
> run since it is kicked in __alloc_pages. But since we cannot
> guarantee that this will never happen...

In this case kreclaimd will be woken up and the free pages
will be refilled.

Rik
--
IA64: a worthy successor to the i860.

		http://www.surriel.com/
http://www.conectiva.com/	http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

Received: from burns.conectiva (burns.conectiva [10.0.0.4])
	by perninha.conectiva.com.br (Postfix) with SMTP id 08F0D38C3C
	for <linux-mm@kvack.org>; Thu, 23 Aug 2001 15:44:55 -0300 (EST)
Date: Thu, 23 Aug 2001 15:44:46 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH NG] alloc_pages_limit & pages_min
In-Reply-To: <200108231841.f7NIf3001564@mailf.telia.com>
Message-ID: <Pine.LNX.4.33L.0108231544340.31410-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Roger Larsson <roger.larsson@norran.net>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 23 Aug 2001, Roger Larsson wrote:

> f we did get one page => we are above pages_min
> try to reach pages_low too.

Yeah, but WHY ?

Rik
--
IA64: a worthy successor to the i860.

		http://www.surriel.com/
http://www.conectiva.com/	http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

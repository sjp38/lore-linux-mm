Date: Mon, 15 May 2000 18:15:55 +0200 (CEST)
From: Ingo Molnar <mingo@elte.hu>
Reply-To: mingo@elte.hu
Subject: Re: [patch] VM stable again?
In-Reply-To: <Pine.LNX.4.21.0005151227010.20410-100000@duckman.distro.conectiva>
Message-ID: <Pine.LNX.4.10.10005151740001.6466-100000@elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 15 May 2000, Rik van Riel wrote:

> It should be per-pgdat. Per-zone probably won't work since having this
> counter per-zone may interfere with both fallback and balancing
> between the zones.

per-pgdat essentially means 'global counter' on a typical SMP system.
Anyway, it's not in the hot path so it doesnt matter that much. (the the
atomic_read() generates a shared cacheline in the typical case)

	Ingo







--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

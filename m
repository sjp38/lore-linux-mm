Date: Mon, 16 Apr 2001 13:52:50 +0200 (MET DST)
From: Szabolcs Szakacsits <szaka@f-secure.com>
Subject: Re: [PATCH] a simple OOM killer to save me from Netscape
In-Reply-To: <m1ofu0t18b.fsf@frodo.biederman.org>
Message-ID: <Pine.LNX.4.30.0104161338580.20939-100000@fs131-224.f-secure.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 14 Apr 2001, Eric W. Biederman wrote:

> Seriously you could do this in user-space with a 16KB or so mlocked
> binary.

You'd need to fix at least these as well, no new memory required to read
from /proc, no minutes latencies and obsolete values when reading /proc.
You're idea already failed in theory. I'd also suggest to study how
others handle the problem, there are a *lot* to learn ;)

	Szaka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

Date: Wed, 15 Aug 2001 20:04:55 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] mmap tail merging
In-Reply-To: <Pine.LNX.4.33.0108151837050.12167-100000@touchme.toronto.redhat.com>
Message-ID: <Pine.LNX.4.33L.0108152004380.5646-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ben LaHaise <bcrl@redhat.com>
Cc: Linus Torvalds <torvalds@transmeta.com>, alan@redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 15 Aug 2001, Ben LaHaise wrote:

> Here's a patch to mmap.c that performs tail merging on mmap.

This patch sure is compact ;)

Rik
--
IA64: a worthy successor to i860.

http://www.surriel.com/		http://distro.conectiva.com/

Send all your spam to aardvark@nl.linux.org (spam digging piggy)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

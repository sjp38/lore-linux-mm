Date: Wed, 3 Jan 2001 13:21:57 -0200 (BRDT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] drop-behind fix for generic_file_write
In-Reply-To: <Pine.LNX.4.21.0101031256040.1403-100000@duckman.distro.conectiva>
Message-ID: <Pine.LNX.4.21.0101031321200.1403-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 3 Jan 2001, Rik van Riel wrote:

> the following (trivial) patch fixes drop-behind behaviour
> in generic_file_write to only drop fully written pages.

OK, please ignore. It is already in  prerelease-diff
in the testing/ directory .. ;)

regards,

Rik
--
Hollywood goes for world dumbination,
	Trailer at 11.

		http://www.surriel.com/
http://www.conectiva.com/	http://distro.conectiva.com.br/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

Received: from burns.conectiva (burns.conectiva [10.0.0.4])
	by perninha.conectiva.com.br (Postfix) with SMTP id F3D5838C4A
	for <linux-mm@kvack.org>; Mon, 20 Aug 2001 14:03:06 -0300 (EST)
Date: Mon, 20 Aug 2001 14:02:54 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: 2.4.8/2.4.9 VM problems
In-Reply-To: <3B813743.5080400@ucla.edu>
Message-ID: <Pine.LNX.4.33L.0108201402140.31410-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin Redelings I <bredelin@ucla.edu>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 20 Aug 2001, Benjamin Redelings I wrote:

> Was it really true, that swapped in pages didn't get marked as
> referenced before?

That's just an artifact of the use-once patch, which
only sets the referenced bit on the _second_ access
to a page.

Rik
--
IA64: a worthy successor to the i860.

		http://www.surriel.com/
http://www.conectiva.com/	http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

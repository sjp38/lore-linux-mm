Received: from burns.conectiva (burns.conectiva [10.0.0.4])
	by perninha.conectiva.com.br (Postfix) with SMTP id 1576238C14
	for <linux-mm@kvack.org>; Mon, 20 Aug 2001 18:38:26 -0300 (EST)
Date: Mon, 20 Aug 2001 18:38:12 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: 2.4.8/2.4.9 VM problems
In-Reply-To: <20010820192613Z16342-32383+573@humbolt.nl.linux.org>
Message-ID: <Pine.LNX.4.33L.0108201837460.31410-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@bonn-fries.net>
Cc: Benjamin Redelings I <bredelin@ucla.edu>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 20 Aug 2001, Daniel Phillips wrote:

> A similar thing has to be done in filemap_nopage (which will
> take care of mmap pages) and also for any filesystems whose page
> accesses bypass generic_read/write,

Either that, or you fix page_launder() like I explained
to you on IRC yesterday ;)

Rik
--
IA64: a worthy successor to the i860.

		http://www.surriel.com/
http://www.conectiva.com/	http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

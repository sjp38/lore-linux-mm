Received: from burns.conectiva (burns.conectiva [10.0.0.4])
	by perninha.conectiva.com.br (Postfix) with SMTP id 29671475FA
	for <linux-mm@kvack.org>; Tue, 22 Oct 2002 17:13:47 -0200 (BRST)
Date: Tue, 22 Oct 2002 17:13:34 -0200 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [patch] generic nonlinear mappings, 2.5.44-mm2-D0
In-Reply-To: <Pine.LNX.4.44.0210221936010.18790-100000@localhost.localdomain>
Message-ID: <Pine.LNX.4.44L.0210221712460.1648-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Andrew Morton <akpm@zip.com.au>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 22 Oct 2002, Ingo Molnar wrote:

> the attached patch (ontop of 2.5.44-mm2) implements generic (swappable!)
> nonlinear mappings and sys_remap_file_pages() support. Ie. no more
> MAP_LOCKED restrictions and strange pagefault semantics.

The code looks sane, but like Christoph, I'm curious why
we need it.

Rik
-- 
A: No.
Q: Should I include quotations after my reply?

http://www.surriel.com/		http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

Date: Fri, 19 May 2000 09:08:54 -0700 (PDT)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [patch] balanced highmem subsystem under pre7-9
In-Reply-To: <Pine.LNX.4.21.0005191150320.20142-100000@duckman.distro.conectiva>
Message-ID: <Pine.LNX.4.21.0005190905200.1099-100000@inspiron.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Ingo Molnar <mingo@elte.hu>, Linus Torvalds <torvalds@transmeta.com>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

On Fri, 19 May 2000, Rik van Riel wrote:

>I'm curious what would be so "very broken" about this?

You start eating from ZONE_DMA before you made empty ZONE_NORMAL.

>AFAICS it does most of what the classzone patch would achieve,
>at lower complexity and better readability.

I disagree.

Andrea


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

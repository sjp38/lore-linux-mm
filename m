Date: Mon, 7 Feb 2000 18:56:42 +0100 (CET)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: 2.2.x Memory subsystem questions
In-Reply-To: <Pine.LNX.4.10.10002071654320.9296-100000@mirkwood.dummy.home>
Message-ID: <Pine.LNX.4.21.0002071856030.806-100000@alpha.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@nl.linux.org>
Cc: Mike Panetta <mpanetta@realminfo.com>, Linux Kernel <linux-kernel@vger.rutgers.edu>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 7 Feb 2000, Rik van Riel wrote:

>The problem with poor VM performance in 2.2 is that the kernel

The first problem that I addressed a few months ago is that if you write
to disk `cp` get swapped out.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

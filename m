Date: Tue, 25 Apr 2000 17:59:59 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [PATCH] 2.3.99-pre6-3+  VM rebalancing
In-Reply-To: <Pine.LNX.4.21.0004251208520.10408-100000@duckman.conectiva>
Message-ID: <Pine.LNX.4.21.0004251757360.9768-100000@alpha.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: riel@nl.linux.org
Cc: Simon Kirby <sim@stormix.com>, linux-mm@kvack.org, "Stephen C. Tweedie" <sct@redhat.com>, Ben LaHaise <bcrl@redhat.com>, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

On Tue, 25 Apr 2000, Rik van Riel wrote:

>If you look closer, you'll see that none of the swapped out
>stuff is swapped back in again. This shows that the VM
>subsystem did make the right choice here...

Swapping out with 50mbyte of cache isn't the right choice unless all the
50mbyte of cache were mapped in memory (and I bet that wasn't the case).

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

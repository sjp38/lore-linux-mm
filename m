Message-ID: <3903D353.D98969B7@mandrakesoft.com>
Date: Mon, 24 Apr 2000 00:53:39 -0400
From: Jeff Garzik <jgarzik@mandrakesoft.com>
MIME-Version: 1.0
Subject: Re: [patch] memory hog protection
References: <Pine.LNX.4.21.0004232255530.1852-100000@duckman.conectiva>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: riel@nl.linux.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> the patch below changes the mm->swap_cnt assignment to put
> memory hogs at a disadvantage to programs with a smaller
> RSS.
[...]

There are many classes of problems where preserving interactivity at the
expense of a resource hog is a bad not good idea.  Think of obscure
situations like database servers for example :)

-- 
Jeff Garzik              | Nothing cures insomnia like the
Building 1024            | realization that it's time to get up.
MandrakeSoft, Inc.       |        -- random fortune
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

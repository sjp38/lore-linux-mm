Date: Mon, 1 May 2000 19:08:37 -0600 (MDT)
From: Roel van der Goot <roel@cs.ualberta.ca>
Subject: Re: [PATCH] pre7-1 semicolon & nicely readableB
Message-ID: <Pine.SOL.3.96.1000501190034.4093K-100000@sexsmith.cs.ualberta.ca>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: riel@nl.linux.org
Cc: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

Hi Rik,

I want to inform you that there is a subtle difference between
the following two loops:

(i)

   while ((mm->swap_cnt << 2 * (i + 1) < max_cnt)
                   && i++ < 10);

(ii)

   while ((mm->swap_cnt << 2 * (i + 1) < max_cnt)
                   && i < 10)
           i++;

Cheers,
Roel.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

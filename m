Date: Tue, 27 Jun 2000 03:27:15 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: Why is the free_list not null-terminated?
In-Reply-To: <20000623193609Z131187-21004+54@kanga.kvack.org>
Message-ID: <Pine.LNX.4.21.0006270323540.2591-100000@inspiron.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Timur Tabi <ttabi@interactivesi.com>
Cc: Linux MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 23 Jun 2000, Timur Tabi wrote:

>Question #1: Does this mean that there are no free zones of Order 2 (16KB)?

It means there are no free contigous chunks of memory of order 2 in such
zone.

>Question #2: Why are prev and next not set to null?  Why do they point

because of linux/include/list.h ;), more seriously that avoids a path in
the list insert/remove code but the head of the list is double size (and
this is not an issue except for large hashtables).

(btw give a try also to SYSRQ+M if you are interested about similar info)

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

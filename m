Date: Tue, 20 Jun 2000 00:43:50 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: shrink_mmap() change in ac-21
In-Reply-To: <Pine.LNX.4.21.0006191905460.1290-100000@duckman.distro.conectiva>
Message-ID: <Pine.LNX.4.21.0006200041500.988-100000@inspiron.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Jamie Lokier <lk@tantalophile.demon.co.uk>, Zlatko Calusic <zlatko@iskon.hr>, alan@redhat.com, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

On Mon, 19 Jun 2000, Rik van Riel wrote:

>Ahh, but we already do this (up to zone->pages_high). It just

more precisely up to zone->pages_high - zone->pages_low/min.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

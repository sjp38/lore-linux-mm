Date: Fri, 20 Apr 2001 15:32:49 +0200 (MET DST)
From: Szabolcs Szakacsits <szaka@f-secure.com>
Subject: Re: suspend processes at load (was Re: a simple OOM ...)
In-Reply-To: <l03130304b705d2c78ae5@[192.168.239.105]>
Message-ID: <Pine.LNX.4.30.0104201525350.20939-100000@fs131-224.f-secure.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jonathan Morton <chromi@cyberspace.org>
Cc: Rik van Riel <riel@conectiva.com.br>, Dave McCracken <dmc@austin.ibm.com>, "James A. Sutherland" <jas88@cam.ac.uk>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 20 Apr 2001, Jonathan Morton wrote:

> Well, OK, let's look at a commercial UNIX known for stability at high load:
> Solaris.  How does Solaris handle thrashing?

Just as 2.2 and earlier kernels did [but not 2.4], keeps processes
running. Moreover the default is non-overcommiting memory handling.
There are also nice performance tuning guides.

	Szaka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

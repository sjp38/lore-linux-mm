Date: Mon, 16 Apr 2001 14:17:52 +0200 (MET DST)
From: Szabolcs Szakacsits <szaka@f-secure.com>
Subject: Re: suspend processes at load (was Re: a simple OOM ...) 
In-Reply-To: <Pine.LNX.4.21.0104131317110.12164-100000@imladris.rielhome.conectiva>
Message-ID: <Pine.LNX.4.30.0104161353270.20939-100000@fs131-224.f-secure.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, linux-mm@kvack.org, Andrew Morton <andrewm@uow.edu.au>
List-ID: <linux-mm.kvack.org>

On Fri, 13 Apr 2001, Rik van Riel wrote:

> That is, when the load gets too high, we temporarily suspend
> processes to bring the load down to more acceptable levels.

Please don't. Or at least make it optional and not the default or user
controllable. Trashing is good. People get feedback system is not
properly setup and they can tune. The problem Linux uses more and more
hardcoded values and "try to be clever algorithms" instead of tuning
parameters (see e.g. read-only /proc/sys/vm/freepages and other place
holders). Suspended pacemakers, quakes, e-commerce web servers, etc is
not the expected behavior and I'm not sure it will make people happy.

This is also my problem with __alloc_pages(), potentially looping
infinitely instead of falling back at one point and let the ENOMEM
handled by the upper layer (trying a smaller order allocation or
whatever).

	Szaka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

Date: Thu, 19 Apr 2001 15:23:15 +0200 (MET DST)
From: Szabolcs Szakacsits <szaka@f-secure.com>
Subject: Re: suspend processes at load (was Re: a simple OOM ...) 
In-Reply-To: <Pine.LNX.4.33.0104181918290.17635-100000@duckman.distro.conectiva>
Message-ID: <Pine.LNX.4.30.0104191506560.20939-100000@fs131-224.f-secure.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: "James A. Sutherland" <jas88@cam.ac.uk>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 18 Apr 2001, Rik van Riel wrote:
> "Painfully slow" when you are thrashing  ==  "root cannot login
> because his login times out every time he tries to login".
> THIS is why we need process suspension in the kernel.

man 5 login.defs
vi /etc/security/limits.conf

> Also think about the problem a bit more.  If the "painfully slow
> progress" is getting less work done than the amount of new work
> that's incoming (think of eg. a mailserver), then the system has
> NO WAY to ever recover ... at least, not without the system
> administrator walking by after the weekend.

This is also quite typical for inexperienced web admins and guess what?
They learn to use resource limits and config settings.

	Szaka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

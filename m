Date: Sun, 15 Sep 2002 14:36:37 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: 2.5.34-mm4
In-Reply-To: <3D84C63E.76526EDE@digeo.com>
Message-ID: <Pine.LNX.4.44L.0209151436080.1857-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: Axel Siebenwirth <axel@hh59.org>, Con Kolivas <conman@kolivas.net>, lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "lse-tech@lists.sourceforge.net" <lse-tech@lists.sourceforge.net>
List-ID: <linux-mm.kvack.org>

On Sun, 15 Sep 2002, Andrew Morton wrote:

> Unfortunately, those updates cause odd-but-not-serious things to
> happen to Red Hat initscripts.  This happens when you install standard
> util-linux as well.  It is due to the initscripts passing in arguments
> which the standard tools do not understand.

I'm about to add all patches from the RH procps rpm to the
procps cvs tree, so this should go away soon.

Rik
-- 
Bravely reimplemented by the knights who say "NIH".

http://www.surriel.com/		http://distro.conectiva.com/

Spamtraps of the month:  september@surriel.com trac@trac.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

Date: Thu, 18 Jul 2002 19:22:17 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] strict VM overcommit for stock 2.4
In-Reply-To: <Pine.LNX.4.30.0207181930170.30902-100000@divine.city.tvnet.hu>
Message-ID: <Pine.LNX.4.44L.0207181921500.12241-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Szakacsits Szabolcs <szaka@sienet.hu>
Cc: Robert Love <rml@tech9.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 18 Jul 2002, Szakacsits Szabolcs wrote:
> On Thu, 18 Jul 2002, Szakacsits Szabolcs wrote:
> > And my point (you asked for comments) was that, this is only (the
> > harder) part of the solution making Linux a more reliable (no OOM
> > killing *and* root always has the control) and cost effective platform
> > (no need for occasionally very complex and continuous resource limit
> > setup/adjusting, especially for inexpert home/etc users).
>
> Ahh, I figured out your target, embedded devices. Yes it's good for
> that but not enough for general purpose.

However, you NEED this patch in order to implement something
that is good enough for general purpose (ie. per-user resource
accounting).

regards,

Rik
-- 
Bravely reimplemented by the knights who say "NIH".

http://www.surriel.com/		http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

Date: Thu, 18 Jul 2002 19:31:53 +0200 (MEST)
From: Szakacsits Szabolcs <szaka@sienet.hu>
Subject: Re: [PATCH] strict VM overcommit for stock 2.4
In-Reply-To: <Pine.LNX.4.30.0207181900390.30902-100000@divine.city.tvnet.hu>
Message-ID: <Pine.LNX.4.30.0207181930170.30902-100000@divine.city.tvnet.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robert Love <rml@tech9.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 18 Jul 2002, Szakacsits Szabolcs wrote:
> And my point (you asked for comments) was that, this is only (the
> harder) part of the solution making Linux a more reliable (no OOM
> killing *and* root always has the control) and cost effective platform
> (no need for occasionally very complex and continuous resource limit
> setup/adjusting, especially for inexpert home/etc users).

Ahh, I figured out your target, embedded devices. Yes it's good for
that but not enough for general purpose.

	Szaka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

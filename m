Date: Mon, 15 Jul 2002 13:34:06 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] Optimize away pte_chains for single mappings
In-Reply-To: <E17U8Qc-0003bk-00@starship>
Message-ID: <Pine.LNX.4.44L.0207151333530.12241-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@arcor.de>
Cc: Matti Aarnio <matti.aarnio@zmailer.org>, Dave McCracken <dmccr@us.ibm.com>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 15 Jul 2002, Daniel Phillips wrote:

> None of these cases apply, the low bit is always masked off before being
> used as a pointer.

Too ugly to live.

Rik
-- 
Bravely reimplemented by the knights who say "NIH".

http://www.surriel.com/		http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

Content-Type: text/plain;
  charset="iso-8859-1"
From: Daniel Phillips <phillips@arcor.de>
Subject: Re: [PATCH] Optimize away pte_chains for single mappings
Date: Mon, 15 Jul 2002 18:42:00 +0200
References: <Pine.LNX.4.44L.0207151333530.12241-100000@imladris.surriel.com>
In-Reply-To: <Pine.LNX.4.44L.0207151333530.12241-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <E17U8vA-0003ca-00@starship>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Matti Aarnio <matti.aarnio@zmailer.org>, Dave McCracken <dmccr@us.ibm.com>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Monday 15 July 2002 18:34, Rik van Riel wrote:
> On Mon, 15 Jul 2002, Daniel Phillips wrote:
> 
> > None of these cases apply, the low bit is always masked off before being
> > used as a pointer.
> 
> Too ugly to live.

That's a nonargument.  I presume you weren't able to think of a
substantive reason.

-- 
Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

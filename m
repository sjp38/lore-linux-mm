Message-Id: <200108231856.f7NIuhv12558@mailg.telia.com>
Content-Type: text/plain;
  charset="iso-8859-1"
From: Roger Larsson <roger.larsson@norran.net>
Subject: Re: [PATCH NG] alloc_pages_limit & pages_min
Date: Thu, 23 Aug 2001 20:52:20 +0200
References: <Pine.LNX.4.33L.0108231544340.31410-100000@duckman.distro.conectiva>
In-Reply-To: <Pine.LNX.4.33L.0108231544340.31410-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thursdayen den 23 August 2001 20:44, Rik van Riel wrote:
> On Thu, 23 Aug 2001, Roger Larsson wrote:
> > f we did get one page => we are above pages_min
> > try to reach pages_low too.
>
> Yeah, but WHY ?
>

* Historic reasons - I feel good at that limit... :-)
 MIN the limit never crossed
 LOW center, our target of free pages - when all zones time to free.
 HIGH limit were to stop the freeing.

-- 
Roger Larsson
Skelleftea
Sweden
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

Message-Id: <l03130317b7455dc1ad86@[192.168.239.105]>
In-Reply-To: <15135.37789.234756.822456@gargle.gargle.HOWL>
References: <l03130312b7444bea56f8@[192.168.239.105]>
 <l03130308b7439bb9f187@[192.168.239.105]>
 <l03130312b7444bea56f8@[192.168.239.105]>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Thu, 7 Jun 2001 17:45:13 +0100
From: Jonathan Morton <chromi@cyberspace.org>
Subject: Re: [PATCH] reapswap for 2.4.5-ac10
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: John Stoffel <stoffel@casc.com>
Cc: Marcelo Tosatti <marcelo@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

At 3:45 pm +0100 7/6/2001, John Stoffel wrote:
>Jonathan> The one which deals with dead swapcache pages.  I want to
>Jonathan> apply the one which actively eats them using kreclaimd, too.
>
>Why do we need yet another daemon to reap pages/swap/cache from the
>system?
>
>Or am I mis-understanding you here and you'd just be adding some stuff
>to kswapd?

It wasn't me.  :)  kreclaimd already exists (i think it shows up as bdflush
in top), the patch I'm looking at adds swapcache-reclaim duties to it.
It's the same family of code as kswapd.

--------------------------------------------------------------
from:     Jonathan "Chromatix" Morton
mail:     chromi@cyberspace.org  (not for attachments)

The key to knowledge is not to rely on people to teach you it.

GCS$/E/S dpu(!) s:- a20 C+++ UL++ P L+++ E W+ N- o? K? w--- O-- M++$ V? PS
PE- Y+ PGP++ t- 5- X- R !tv b++ DI+++ D G e+ h+ r++ y+(*)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

Message-Id: <l03130328b745e9637be5@[192.168.239.105]>
In-Reply-To: 
        <Pine.LNX.4.21.0106072138030.1156-100000@freak.distro.conectiva>
References: <l03130326b745e267d7e8@[192.168.239.105]>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Fri, 8 Jun 2001 03:35:46 +0100
From: Jonathan Morton <chromi@cyberspace.org>
Subject: Re: [PATCH] VM tuning patch, take 2
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>> Or have you just found a bug in your own code?  :)
>
>Yes, my code is also broken.
>
>It should be:
>
>	progress = try_to_free_pages(gfp_mask);
>
>	if (!progress) {
>		if (gfp_mask & __GFP_IO) {
>			wakeup_kswapd(1);
>			goto try_again;
>		} else
>			return NULL;
>	} else
>		goto try_again;
>
>
>Also note that my code makes non-zero order allocations loop like mad
>here. You may want to fix that, too.

Sorry, I don't have time to fix anything else today - I'm already pressed
for time on preparing a presentation for Philips Semiconductors (there's a
cash prize involved).  Explanation: I'm studying Computer Systems
Engineering, so I get to do Electronics as well as Computing.

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

Message-ID: <20040825204621.74650.qmail@web14305.mail.yahoo.com>
Date: Wed, 25 Aug 2004 13:46:21 -0700 (PDT)
From: Kanoj Sarcar <kanojsarcar@yahoo.com>
Subject: Re: Documentation/vm/balance really outdated
In-Reply-To: <20040825184520.GA23878@logos.cnet>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>, linux-mm@kvack.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

Hi,

--- Marcelo Tosatti <marcelo.tosatti@cyclades.com>
wrote:

> Hi guys,
> 
> The file Documentation/vm/balance was written by
> Kanoj in 2000, and is completly outdated 
> to what we have now.
> 
> Last paragraph:
> 
>
pages_min/pages_low/pages_high/low_on_memory/zone_wake_kswapd:
> These are
> per-zone fields, used to determine when a zone needs
> to be balanced. When
> the number of pages falls below pages_min, the
> hysteric field low_on_memory
> gets set. This stays set till the number of free
> pages becomes pages_high.
> When low_on_memory is set, page allocation requests
> will try to free some
> pages in the zone (providing GFP_WAIT is set in the
> request). Orthogonal
> to this, is the decision to poke kswapd to free some
> zone pages. That
> decision is not hysteresis based, and is done when
> the number of free
> pages is below pages_low; in which case
> zone_wake_kswapd is also set.
> 
> Should we just remove it? 
> 

Thats the easy solution; a better one would be if 
some (one | people) volunteer(s) to update that file.

If you do remove it, also consider the files "numa"
and "locking" for removal/updates, I know they are 
also quite out of date.

Thanks.

Kanoj



		
__________________________________
Do you Yahoo!?
Yahoo! Mail Address AutoComplete - You start. We finish.
http://promotions.yahoo.com/new_mail 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

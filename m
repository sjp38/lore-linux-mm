Date: Sun, 2 Sep 2001 10:14:22 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: VM change in 2.4.10-pre3: don't call swap_out unless shortage
In-Reply-To: <3B916FF3.6040300@ucla.edu>
Message-ID: <Pine.LNX.4.33L.0109021012190.24097-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin Redelings I <bredelin@ucla.edu>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 1 Sep 2001, Benjamin Redelings I wrote:

> I guess what I am really wondering is if there is some way that we
> could continue calling refill_inactive_scan while never calling
> swap_out (or only rarely).

You're absolutely right. Guess why Linus moved swap_out()
to before refill_inactive_scan() in the first place ?  ;)

> Anyway, thanks for any explanation of what I'm missing!
>
> -BenRI, looking forwards to reverse mapping...

I think you haven't missed a single detail here. Reverse
mappings would indeed get rid of the whole unbalanced mess
we have right now.

regards,

Rik
-- 
IA64: a worthy successor to i860.

http://www.surriel.com/		http://distro.conectiva.com/

Send all your spam to aardvark@nl.linux.org (spam digging piggy)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

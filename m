Date: Thu, 16 Aug 2001 21:46:59 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: Swapping for diskless nodes
In-Reply-To: <20010816234639.E755@bug.ucw.cz>
Message-ID: <Pine.LNX.4.33L.0108162146120.5646-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pavel Machek <pavel@suse.cz>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Bulent Abali <abali@us.ibm.com>, "Dirk W. Steinberg" <dws@dirksteinberg.de>, Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 16 Aug 2001, Pavel Machek wrote:

> I'd call that configuration error. If swap-over-nbd works in all but
> such cases, its okay with me.

Agreed. I'm very interested in this case too, I guess we
should start testing swap-over-nbd and trying to fix things
as we encounter them...

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

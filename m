From: Benno Senoner <sbenno@gardena.net>
Subject: Re: [linux-audio-dev] Re: new latency report
Date: Sun, 9 Jul 2000 20:13:47 +0200
Content-Type: text/plain
References: <E13BL8P-00022Z-00@the-village.bc.nu>
In-Reply-To: <E13BL8P-00022Z-00@the-village.bc.nu>
MIME-Version: 1.0
Message-Id: <00070920393600.02245@smp>
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>, Roger Larsson <roger.larsson@norran.net>
Cc: "linux-kernel@vger.rutgers.edu" <linux-kernel@vger.rutgers.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-audio-dev@ginette.musique.umontreal.ca" <linux-audio-dev@ginette.musique.umontreal.ca>
List-ID: <linux-mm.kvack.org>

On Sun, 09 Jul 2000, Alan Cox wrote:
> > and the 704ms used to busy loop in modprobe...
> > (SB16 non PnP)
> 
> I take patches for the sb16 if it bugs you enough to fix it.

The point is that modprobe will be a general problem:
many modules will freeze your box for dozen if not hundreds of msecs.
( eg aic7xxx )

We can live with this if we require that the user insmods all the modules
at  boottime. 

The problem could be the audiomatic module loading / cleaning 
(kmod).

For example how do we know in advance that the user wants to use
pppd ? (ppp.o , slhc.o )

If he is offline while doing low-latency audio , and suddenly needs
something from the net, as soon as he fires up pppd, a latency-peak
may occur.

So a  way to avoid latency peaks would be to inform the user, that
if (during his audio recording sessions) he wants to do some stuff which
requires module loading , he has to preload the modules at boottime,
and disable automatic module cleanup.

Anyone better ideas ?

Benno.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

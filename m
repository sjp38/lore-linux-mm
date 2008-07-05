Date: Fri, 4 Jul 2008 17:51:18 -0700 (PDT)
From: Trent Piepho <tpiepho@freescale.com>
Subject: Re: [bug?] tg3: Failed to load firmware "tigon/tg3_tso.bin"
In-Reply-To: <20080704235839.GA5649@khazad-dum.debian.net>
Message-ID: <Pine.LNX.4.64.0807041742500.13075@t2.domain.actdsltmp>
References: <486D6DDB.4010205@infradead.org> <87ej6armez.fsf@basil.nowhere.org>
 <1215177044.10393.743.camel@pmac.infradead.org> <486E2260.5050503@garzik.org>
 <1215178035.10393.763.camel@pmac.infradead.org> <20080704141014.GA23215@mit.edu>
 <s5habgxloct.wl%tiwai@suse.de> <486E3622.1000900@suse.de>
 <1215182557.10393.808.camel@pmac.infradead.org> <20080704231322.GA4410@dspnet.fr.eu.org>
 <20080704235839.GA5649@khazad-dum.debian.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Henrique de Moraes Holschuh <hmh@hmh.eng.br>
Cc: Olivier Galibert <galibert@pobox.com>, David Woodhouse <dwmw2@infradead.org>, Hannes Reinecke <hare@suse.de>, Takashi Iwai <tiwai@suse.de>, Theodore Tso <tytso@mit.edu>, Jeff Garzik <jeff@garzik.org>, Andi Kleen <andi@firstfloor.org>, David Miller <davem@davemloft.net>, hugh@veritas.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, mchan@broadcom.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 4 Jul 2008, Henrique de Moraes Holschuh wrote:
> On Sat, 05 Jul 2008, Olivier Galibert wrote:
>> Won't that break multiple kernel installs on any binary packaging
>> system that cares about file collisions?  Multiple kernel rpms
>> providing the same /lib/firmware files would break things wouldn't
>> they ?
>
> We will probably need per-kernel directories, exactly like what is done for
> modules.  And since there are (now) both kernel-version-specific, and
> non-kernel-version-specific firmware, this means the firmware loader should
> look first on the version-specific directory (say, /lib/firmware/$(uname
> -r)/), then if not found, on the general directory (/lib/firmware).

How about /lib/modules/`uname -r`/firmware

Keeps all the stuff for a given kernel together in one directory.  Easier to
delete, e.g. when getting ride of an old kernel or when wiping a broken kernel
install clean.  The non-kernel-specific directory could be for firmwares that
don't come with the kernel and aren't specific to the driver version.  That
avoids the complexity of providing kernel version specific packages when it's
not necessary.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

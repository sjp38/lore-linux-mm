Date: Fri, 19 Nov 1999 15:52:26 -0200 (EDT)
From: Christian Robottom Reis <kiko@radiumsystems.com.br>
Subject: Re: 128M
In-Reply-To: <Pine.LNX.4.10.9911171033130.655-100000@robleda.iit.upco.es>
Message-ID: <Pine.LNX.4.10.9911191549490.15845-100000@know.radiumsystems.com.br>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jesus Peco <peco@iit.upco.es>
Cc: MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 17 Nov 1999, Jesus Peco wrote:

>    I have a Pentium II celeron and RedHat6.0 with
> 128M RAM. I have just recompiled the kernel 2.2.5-15
> for a pentium II processor.

I had a similar problem with a PII earlier in the month

> /sbin/lilo -v
> 
> which reports that I only have 64M. I reboot and

You _must_ reboot for the kernel to redetect memory.
Try booting lilo with shift pressed and writing mem=128M manually. And
take care if the memory is shared between VRAM and RAM.

> Do I have a hardware problem?
> Is it a software configuration problem?

Does BIOS report the correct amount of memory?

Cheers,
--
_/\ Christian Reis is eleet@altern.org and kiko@radiumsystems.com.br 
\ / suicide architect | free software advocate | mountain biker 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/

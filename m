From: Daniel Phillips <phillips@arcor.de>
Subject: Re: 2.5.74-mm1
Date: Sun, 6 Jul 2003 02:10:32 +0200
References: <20030703023714.55d13934.akpm@osdl.org> <200307051728.12891.phillips@arcor.de> <20030705121416.62afd279.akpm@osdl.org>
In-Reply-To: <20030705121416.62afd279.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200307060210.32021.phillips@arcor.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Saturday 05 July 2003 21:14, Andrew Morton wrote:
> Daniel Phillips <phillips@arcor.de> wrote:
> > Kgdb is no help in
> > diagnosing, as the kgdb stub also goes comatose, or at least the serial
> > link does.  No lockups have occurred so far when I was not interacting
> > with the system via the keyboard or mouse.  Suggestions?
>
> Enable IO APIC, Local APIC, nmi watchdog.  Use serial console, see if you
> can get a sysrq trace out of it.  That's `^A F T' in minicom.

OK, tried that.  Still very dead.

> I mean, it _has_ to be either stuck with interrupts on, or stuck with them
> off.

Interesting data: it always hangs on the 4th iteration of Ctrl-Alt-F7, 
Ctrl-Alt-F2.  This smells like a bios stack overflow.  I think I'd better go 
poke at the vendor at this point, no?

I do feel Linux is exonerated, but then this just shows why we need to keep on 
moving, right on into the bios.

Regards,

Daniel



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

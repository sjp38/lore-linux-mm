Received: from bigblue.dev.mcafeelabs.com
	by xmailserver.org with [XMail 1.16 (Linux/Ix86) ESMTP Server]
	id <SA19B3> for <linux-mm@kvack.org> from <davidel@xmailserver.org>;
	Sat, 05 Jul 2003 17:24:44 -0700
Date: Sat, 5 Jul 2003 17:10:56 -0700 (PDT)
From: Davide Libenzi <davidel@xmailserver.org>
Subject: Re: 2.5.74-mm1
In-Reply-To: <200307060210.32021.phillips@arcor.de>
Message-ID: <Pine.LNX.4.55.0307051710030.4599@bigblue.dev.mcafeelabs.com>
References: <20030703023714.55d13934.akpm@osdl.org> <200307051728.12891.phillips@arcor.de>
 <20030705121416.62afd279.akpm@osdl.org> <200307060210.32021.phillips@arcor.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@arcor.de>
Cc: Andrew Morton <akpm@osdl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 6 Jul 2003, Daniel Phillips wrote:

> On Saturday 05 July 2003 21:14, Andrew Morton wrote:
> > Daniel Phillips <phillips@arcor.de> wrote:
> > > Kgdb is no help in
> > > diagnosing, as the kgdb stub also goes comatose, or at least the serial
> > > link does.  No lockups have occurred so far when I was not interacting
> > > with the system via the keyboard or mouse.  Suggestions?
> >
> > Enable IO APIC, Local APIC, nmi watchdog.  Use serial console, see if you
> > can get a sysrq trace out of it.  That's `^A F T' in minicom.
>
> OK, tried that.  Still very dead.

Last resort, LKCD ;)



- Davide

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

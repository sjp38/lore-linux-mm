Date: Fri, 10 Dec 1999 00:44:58 +0100
Message-Id: <199912092344.AAA01364@agnes.faerie.monroyaume>
From: JF Martinez <jfm2@club-internet.fr>
In-reply-to: <199912092332.AAA27593@cave.bitwizard.nl>
	(R.E.Wolff@BitWizard.nl)
Subject: Re: Getting big areas of memory, in 2.3.x?
References: <199912092332.AAA27593@cave.bitwizard.nl>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: mingo@chiara.csoma.elte.hu
Cc: wje@cthulhu.engr.sgi.com, R.E.Wolff@BitWizard.nl.jgarzik, @mandrakesoft.com, alan@lxorguk.ukuu.org.uk, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> 
> Ingo Molnar wrote:
> > yep, if eg. an fsck happened before modules are loaded then RAM is filled
> > up with the buffer-cache. The best guarantee is to compile such drivers
> > into the kernel.
> 

Modules are crucial.  The best gurantee is fix the problem and keep the
drivers where they must be: in modules not in the main kernel.

-- 
			Jean Francois Martinez

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/

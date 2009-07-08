Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id D54BA6B004F
	for <linux-mm@kvack.org>; Wed,  8 Jul 2009 08:19:49 -0400 (EDT)
Date: Wed, 8 Jul 2009 14:28:29 +0200 (CEST)
From: Guennadi Liakhovetski <g.liakhovetski@gmx.de>
Subject: Re: [BUG 2.6.30] Bad page map in process
In-Reply-To: <20090708132308.12b25ac9@hcegtvedt.norway.atmel.com>
Message-ID: <Pine.LNX.4.64.0907081326000.15633@axis700.grange>
References: <Pine.LNX.4.64.0907081250110.15633@axis700.grange>
 <20090708132308.12b25ac9@hcegtvedt.norway.atmel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Hans-Christian Egtvedt <hans-christian.egtvedt@atmel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel@avr32linux.org
List-ID: <linux-mm.kvack.org>

On Wed, 8 Jul 2009, Hans-Christian Egtvedt wrote:

> On Wed, 8 Jul 2009 13:07:31 +0200 (CEST)
> Guennadi Liakhovetski <g.liakhovetski@gmx.de> wrote:
> 
> Hi Guennadi,
> 
> > with a 2.6.30 kernel 
> >
> 
> Could you give a short description of the rest of your setup as well?

Sure, it is based on buildroot v2.3.0:

> libc library and version number? Latest known to be good is uClibc
> v0.9.30.1.

It's v0.9.30.

> binutils version? Latest known to be good is binutils version
> 2.18.atmel.1.0.1.buildroot.1.

Yep.

> gcc version? Latest known to be good is gcc version
> 4.2.2-atmel.1.1.3.buildroot.1.

Yep.

Thanks
Guennadi
---
Guennadi Liakhovetski, Ph.D.
Freelance Open-Source Software Developer
http://www.open-technology.de/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

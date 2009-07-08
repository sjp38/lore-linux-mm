Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 4DA6F6B004D
	for <linux-mm@kvack.org>; Wed,  8 Jul 2009 07:15:16 -0400 (EDT)
Date: Wed, 8 Jul 2009 13:23:08 +0200
From: Hans-Christian Egtvedt <hans-christian.egtvedt@atmel.com>
Subject: Re: [BUG 2.6.30] Bad page map in process
Message-ID: <20090708132308.12b25ac9@hcegtvedt.norway.atmel.com>
In-Reply-To: <Pine.LNX.4.64.0907081250110.15633@axis700.grange>
References: <Pine.LNX.4.64.0907081250110.15633@axis700.grange>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Guennadi Liakhovetski <g.liakhovetski@gmx.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel@avr32linux.org
List-ID: <linux-mm.kvack.org>

On Wed, 8 Jul 2009 13:07:31 +0200 (CEST)
Guennadi Liakhovetski <g.liakhovetski@gmx.de> wrote:

Hi Guennadi,

> with a 2.6.30 kernel 
>

Could you give a short description of the rest of your setup as well?

libc library and version number? Latest known to be good is uClibc
v0.9.30.1.

binutils version? Latest known to be good is binutils version
2.18.atmel.1.0.1.buildroot.1.

gcc version? Latest known to be good is gcc version
4.2.2-atmel.1.1.3.buildroot.1.

<snipp link to patch and BUG output>

-- 
Best regards,
Hans-Christian Egtvedt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

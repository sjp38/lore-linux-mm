Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 2289F6B004F
	for <linux-mm@kvack.org>; Mon, 13 Jul 2009 06:51:53 -0400 (EDT)
Date: Mon, 13 Jul 2009 13:14:34 +0200 (CEST)
From: Guennadi Liakhovetski <g.liakhovetski@gmx.de>
Subject: Re: SV: [BUG 2.6.30] Bad page map in process
In-Reply-To: <1DC0FF5051B91B4D88A15F21F1A27F417ABDE6@dware1013.doorway.loc>
Message-ID: <Pine.LNX.4.64.0907131312160.4212@axis700.grange>
References: <Pine.LNX.4.64.0907081250110.15633@axis700.grange><Pine.LNX.4.64.0907101900570.27223@sister.anvils><20090712095731.3090ef56@siona>
 <Pine.LNX.4.64.0907122151010.13280@axis700.grange>
 <1DC0FF5051B91B4D88A15F21F1A27F417ABDE6@dware1013.doorway.loc>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Eirik Aanonsen <eaa@wprmedical.com>
Cc: Haavard Skinnemoen <haavard.skinnemoen@atmel.com>, linux-mm@kvack.org, Hugh Dickins <hugh.dickins@tiscali.co.uk>, kernel@avr32linux.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 13 Jul 2009, Eirik Aanonsen wrote:

> 
> 
> >We're currently trying to investigate and fix the hardware, will post our 
> >results.
> >
> >Thanks
> >Guennadi
> 
> ---
> 
> Are you sure this is not a compiler bug related to using version
> gcc version 4.2.2-atmel.1.0.8
> instead of using:
> gcc version 4.2.2.atmel.1.1.3

The kernel and the application are compiled with 1.1.3, the rest of the 
system should be too, not 100% sure though. I really think it is, would 
have to double check.

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

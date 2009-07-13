Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id C10FE6B004F
	for <linux-mm@kvack.org>; Mon, 13 Jul 2009 07:34:10 -0400 (EDT)
Date: Mon, 13 Jul 2009 12:56:17 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [BUG 2.6.30] Bad page map in process
In-Reply-To: <Pine.LNX.4.64.0907122151010.13280@axis700.grange>
Message-ID: <Pine.LNX.4.64.0907131236320.20647@sister.anvils>
References: <Pine.LNX.4.64.0907081250110.15633@axis700.grange>
 <Pine.LNX.4.64.0907101900570.27223@sister.anvils> <20090712095731.3090ef56@siona>
 <Pine.LNX.4.64.0907122151010.13280@axis700.grange>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Guennadi Liakhovetski <g.liakhovetski@gmx.de>
Cc: Haavard Skinnemoen <haavard.skinnemoen@atmel.com>, linux-mm@kvack.org, kernel@avr32linux.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sun, 12 Jul 2009, Guennadi Liakhovetski wrote:
> 
> 2. the specific BUG that I posted originally wasn't very interesting, 
> because it wasn't the first one. Having read a few posts I wasn't quite 
> sure how really severe this BUG was, i.e., whether or not it requiret a 
> reboot. There used to be a message like "reboot is required" around this 
> sort of exceptions, but then it has been removed, so, I thought, it wasn't 
> required any more. But the fact is, that once one such BUG has occurred, 
> new ones will come from various applications and eventually the system 
> will become unusable.

I replaced Bad page state's reboot is needed message by just the BUG
prefix: partly because the bad page handling _is_ now more resilient;
but more because I don't like wasting screenlines which could hold
vital info, and because I didn't see how this BUG differs from others
in whether or not you need a reboot.

A BUG means the kernel is in unknown territory: if you're brave and
want to gather more info, you try to keep on running after a BUG;
if you're cautious, you reboot as soon as possible.

(Hmm, but perhaps I should wire these in to panic_on_oops??)

You did the right thing: kept on running, then decided it wasn't
worth it.  (But you've only sent the one pair of messages gathered:
okay, let's forget the rest until you've sorted the hardware angle.)

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

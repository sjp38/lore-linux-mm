Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id B59626B0047
	for <linux-mm@kvack.org>; Tue,  2 Mar 2010 17:15:01 -0500 (EST)
Date: Tue, 2 Mar 2010 22:17:51 +0000
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: Memory management woes - order 1 allocation failures
Message-ID: <20100302221751.20addf02@lxorguk.ukuu.org.uk>
In-Reply-To: <20100302211603.GD11355@csn.ul.ie>
References: <alpine.DEB.2.00.1002261042020.7719@router.home>
	<84144f021002260917q61f7c255rf994425f3a613819@mail.gmail.com>
	<20100301103546.DD86.A69D9226@jp.fujitsu.com>
	<20100302172606.GA11355@csn.ul.ie>
	<20100302183451.75d44f03@lxorguk.ukuu.org.uk>
	<20100302191110.GB11355@csn.ul.ie>
	<20100302192942.GA2953@suse.de>
	<20100302211603.GD11355@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Greg KH <gregkh@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Christoph Lameter <cl@linux-foundation.org>, Frans Pop <elendil@planet.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> -#define TTY_BUFFER_PAGE		((PAGE_SIZE  - 256) / 2)
> +#define TTY_BUFFER_PAGE	(((PAGE_SIZE - sizeof(struct tty_buffer)) / 2) & ~0xFF)

Yes agreed I missed a '-1'

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

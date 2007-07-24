Received: from root by ciao.gmane.org with local (Exim 4.43)
	id 1IDNC2-0000i5-Q1
	for linux-mm@kvack.org; Tue, 24 Jul 2007 18:25:02 +0200
Received: from mail.artimi.com ([194.72.81.2])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Tue, 24 Jul 2007 18:25:02 +0200
Received: from frank by mail.artimi.com with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Tue, 24 Jul 2007 18:25:02 +0200
From: Frank Kingswood <frank@kingswood-consulting.co.uk>
Subject: Re: -mm merge plans for 2.6.23 - Completely Fair Swap Prefetch
Date: Tue, 24 Jul 2007 17:11:50 +0100
Message-ID: <f858c6$2k3$1@sea.gmane.org>
References: <20070710013152.ef2cd200.akpm@linux-foundation.org>	 <200707102015.44004.kernel@kolivas.org>	 <9a8748490707231608h453eefffx68b9c391897aba70@mail.gmail.com>	 <46A57068.3070701@yahoo.com.au> <2c0942db0707232153j3670ef31kae3907dff1a24cb7@mail.gmail.com> <46A58B49.3050508@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
In-Reply-To: <46A58B49.3050508@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: ck@vds.kolivas.org
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:

> However, if we can improve basic page reclaim where it is obviously
> lacking, that is always preferable. eg: being a highly speculative
> operation, swap prefetch is not great for power efficiency -- but we
> still want laptop users to have a good experience as well, right?

Maybe we need someone (say, a Redhat engineer) to develop a "Completely 
Fair Swap Prefetch"?

Frank

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

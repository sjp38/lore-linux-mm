Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate1.de.ibm.com (8.12.10/8.12.10) with ESMTP id j8TFc2OI105396
	for <linux-mm@kvack.org>; Thu, 29 Sep 2005 15:38:02 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j8TFc19P176468
	for <linux-mm@kvack.org>; Thu, 29 Sep 2005 17:38:01 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11/8.13.3) with ESMTP id j8TFc1Uf030859
	for <linux-mm@kvack.org>; Thu, 29 Sep 2005 17:38:01 +0200
Subject: Re: [patch 1/6] Page host virtual assist: base patch.
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Reply-To: schwidefsky@de.ibm.com
In-Reply-To: <1128006716.6339.14.camel@localhost>
References: <20050929131525.GB5700@skybase.boeblingen.de.ibm.com>
	 <1128006716.6339.14.camel@localhost>
Content-Type: text/plain
Date: Thu, 29 Sep 2005 17:38:11 +0200
Message-Id: <1128008292.4914.8.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: linux-mm <linux-mm@kvack.org>, frankeh@watson.ibm.com, rhim@cc.gatech.edu
List-ID: <linux-mm.kvack.org>

On Thu, 2005-09-29 at 08:11 -0700, Dave Hansen wrote:
> On Thu, 2005-09-29 at 15:15 +0200, Martin Schwidefsky wrote:
> > Allocated pages start out in stable state. What prevents a page from
> > being made volatile? There are 10 conditions:
> ...
> > 5) The page is anonymous. The page has no backing, can't recreate it.
> 
> Anonymous pages still in the swap cache have backing, right?
> 
> -- Dave

Correct.

-- 
blue skies,
   Martin

Martin Schwidefsky
Linux for zSeries Development & Services
IBM Deutschland Entwicklung GmbH


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate2.de.ibm.com (8.13.6/8.13.6) with ESMTP id k3OEf6iJ089462
	for <linux-mm@kvack.org>; Mon, 24 Apr 2006 14:41:06 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.12.10/NCO/VER6.8) with ESMTP id k3OEgAGv112198
	for <linux-mm@kvack.org>; Mon, 24 Apr 2006 16:42:10 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11/8.13.3) with ESMTP id k3OEf67i031018
	for <linux-mm@kvack.org>; Mon, 24 Apr 2006 16:41:06 +0200
Subject: Re: [patch 1/8] Page host virtual assist: unused / free pages.
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Reply-To: schwidefsky@de.ibm.com
In-Reply-To: <200604241607.15131.ak@suse.de>
References: <20060424123423.GB15817@skybase> <200604241607.15131.ak@suse.de>
Content-Type: text/plain
Date: Mon, 24 Apr 2006 16:41:10 +0200
Message-Id: <1145889670.5241.3.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: linux-mm@kvack.org, akpm@osdl.org, frankeh@watson.ibm.com, rhim@cc.gatech.edu
List-ID: <linux-mm.kvack.org>

On Mon, 2006-04-24 at 16:07 +0200, Andi Kleen wrote:
> On Monday 24 April 2006 14:34, Martin Schwidefsky wrote:
> 
> > +#define page_hva_set_unused(_page)		do { } while (0)
> > +#define page_hva_set_stable(_page)		do { } while (0)
> 
> The whole thing seems quite under commented in the code and illnamed
> (if you didn't know what page_hva_set_unused() is supposed to do
> already would you figure it out from the name?) 

Well, we can always add comments if something is unclear. The name
should give you a good hint though: page-(hva)-set-unused. You set the
page to the unused state. Is the name really that confusing ?

-- 
blue skies,
  Martin.

Martin Schwidefsky
Linux for zSeries Development & Services
IBM Deutschland Entwicklung GmbH

"Reality continues to ruin my life." - Calvin.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

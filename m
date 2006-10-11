Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate6.de.ibm.com (8.13.8/8.13.8) with ESMTP id k9BF7Eks131652
	for <linux-mm@kvack.org>; Wed, 11 Oct 2006 15:07:14 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k9BF9ZNm3076342
	for <linux-mm@kvack.org>; Wed, 11 Oct 2006 17:09:35 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k9BF7D9F003687
	for <linux-mm@kvack.org>; Wed, 11 Oct 2006 17:07:13 +0200
Subject: Re: [patch 3/3] mm: add arch_alloc_page
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Reply-To: schwidefsky@de.ibm.com
In-Reply-To: <20061011145643.GA5259@wotan.suse.de>
References: <20061007105758.14024.70048.sendpatchset@linux.site>
	 <20061007105824.14024.85405.sendpatchset@linux.site>
	 <20061007134345.0fa1d250.akpm@osdl.org> <452856E4.60705@yahoo.com.au>
	 <1160578104.634.2.camel@localhost>  <20061011145643.GA5259@wotan.suse.de>
Content-Type: text/plain
Date: Wed, 11 Oct 2006 17:07:16 +0200
Message-Id: <1160579236.634.12.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@osdl.org>, Linux Memory Management <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2006-10-11 at 16:56 +0200, Nick Piggin wrote:
> > With Nicks patch I can use arch_alloc_page instead of page_set_stable,
> > but I can still not use arch_free_page instead of page_set_unused
> > because it is done before the check for reserved pages. If reserved
> > pages go away or the arch_free_page call would get moved after the check
> > I could replace page_set_unused as well. So with Nicks patch we are only
> > halfway there..
> 
> Ahh, but with my patchSET I think we are all the way there ;)

Oh, good. Then I only have to add two more state change functions,
namely page_make_stable and page_make_volatile.

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

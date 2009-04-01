Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id DA20C6B003D
	for <linux-mm@kvack.org>; Wed,  1 Apr 2009 04:13:28 -0400 (EDT)
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate7.de.ibm.com (8.14.3/8.13.8) with ESMTP id n318Daea073644
	for <linux-mm@kvack.org>; Wed, 1 Apr 2009 08:13:36 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n318Dak94194538
	for <linux-mm@kvack.org>; Wed, 1 Apr 2009 10:13:36 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n318DZ6q032261
	for <linux-mm@kvack.org>; Wed, 1 Apr 2009 10:13:35 +0200
Date: Wed, 1 Apr 2009 10:13:34 +0200
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: Re: [patch 2/6] Guest page hinting: volatile swap cache.
Message-ID: <20090401101334.7e6ea848@skybase>
In-Reply-To: <49D2CD28.9080700@redhat.com>
References: <20090327150905.819861420@de.ibm.com>
	<20090327151011.798602788@de.ibm.com>
	<49D2CD28.9080700@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.osdl.org, frankeh@watson.ibm.com, akpm@osdl.org, nickpiggin@yahoo.com.au, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

On Tue, 31 Mar 2009 22:10:48 -0400
Rik van Riel <riel@redhat.com> wrote:

> Martin Schwidefsky wrote:
> > From: Martin Schwidefsky <schwidefsky@de.ibm.com>
> > From: Hubertus Franke <frankeh@watson.ibm.com>
> > From: Himanshu Raj
> > 
> > The volatile page state can be used for anonymous pages as well, if
> > they have been added to the swap cache and the swap write is finished.
> 
> > Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
> 
> Acked-by: Rik van Riel <riel@redhat.com>

Thanks you for the review. I'll add the Acked-by.

-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

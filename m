Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id 113AB6B005A
	for <linux-mm@kvack.org>; Thu,  6 Sep 2012 18:29:40 -0400 (EDT)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Thu, 6 Sep 2012 16:29:39 -0600
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 3F4FE19D8043
	for <linux-mm@kvack.org>; Thu,  6 Sep 2012 16:29:35 -0600 (MDT)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q86MTYdX241348
	for <linux-mm@kvack.org>; Thu, 6 Sep 2012 16:29:34 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q86MTY6L006717
	for <linux-mm@kvack.org>; Thu, 6 Sep 2012 16:29:34 -0600
Date: Thu, 6 Sep 2012 15:29:33 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] slab: fix the DEADLOCK issue on l3 alien lock
Message-ID: <20120906222933.GR2448@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <5044692D.7080608@linux.vnet.ibm.com>
 <5046B9EE.7000804@linux.vnet.ibm.com>
 <0000013996b6f21d-d45be653-3111-4aef-b079-31dc673e6fd8-000000@email.amazonses.com>
 <504812E7.3000700@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <504812E7.3000700@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Wang <wangyun@linux.vnet.ibm.com>
Cc: Christoph Lameter <cl@linux.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Matt Mackall <mpm@selenic.com>, Pekka Enberg <penberg@kernel.org>

On Thu, Sep 06, 2012 at 11:05:11AM +0800, Michael Wang wrote:
> On 09/05/2012 09:55 PM, Christoph Lameter wrote:
> > On Wed, 5 Sep 2012, Michael Wang wrote:
> > 
> >> Since the cachep and cachep->slabp_cache's l3 alien are in the same lock class,
> >> fake report generated.
> > 
> > Ahh... That is a key insight into why this occurs.
> > 
> >> This should not happen since we already have init_lock_keys() which will
> >> reassign the lock class for both l3 list and l3 alien.
> > 
> > Right. I was wondering why we still get intermitted reports on this.
> > 
> >> This patch will invoke init_lock_keys() after we done enable_cpucache()
> >> instead of before to avoid the fake DEADLOCK report.
> > 
> > Acked-by: Christoph Lameter <cl@linux.com>
> 
> Thanks for your review.
> 
> And add Paul to the cc list(my skills on mailing is really poor...).

Tested-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

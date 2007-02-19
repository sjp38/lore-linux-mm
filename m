Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e36.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l1JJVVW1008920
	for <linux-mm@kvack.org>; Mon, 19 Feb 2007 14:31:31 -0500
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by westrelay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l1JJVUOE495168
	for <linux-mm@kvack.org>; Mon, 19 Feb 2007 12:31:30 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l1JJVUAI024789
	for <linux-mm@kvack.org>; Mon, 19 Feb 2007 12:31:30 -0700
Subject: Re: [PATCH 1/7] Introduce the pagetable_operations and associated
	helper macros.
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <1171910483.3531.87.camel@laptopd505.fenrus.org>
References: <20070219183123.27318.27319.stgit@localhost.localdomain>
	 <20070219183133.27318.92920.stgit@localhost.localdomain>
	 <1171910483.3531.87.camel@laptopd505.fenrus.org>
Content-Type: text/plain
Date: Mon, 19 Feb 2007 13:31:29 -0600
Message-Id: <1171913489.22940.26.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Arjan van de Ven <arjan@infradead.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 2007-02-19 at 19:41 +0100, Arjan van de Ven wrote:
> On Mon, 2007-02-19 at 10:31 -0800, Adam Litke wrote:
> > Signed-off-by: Adam Litke <agl@us.ibm.com>
> > ---
> > 
> >  include/linux/mm.h |   25 +++++++++++++++++++++++++
> >  1 files changed, 25 insertions(+), 0 deletions(-)
> > 
> > diff --git a/include/linux/mm.h b/include/linux/mm.h
> > index 2d2c08d..a2fa66d 100644
> > --- a/include/linux/mm.h
> > +++ b/include/linux/mm.h
> > @@ -98,6 +98,7 @@ struct vm_area_struct {
> >  
> >  	/* Function pointers to deal with this struct. */
> >  	struct vm_operations_struct * vm_ops;
> > +	struct pagetable_operations_struct * pagetable_ops;
> >  
> 
> please make it at least const, those things have no business ever being
> written to right? And by making them const the compiler helps catch
> that, and as bonus the data gets moved to rodata so that it won't share
> cachelines with anything that gets dirty

Yep I agree.  Changed.

-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

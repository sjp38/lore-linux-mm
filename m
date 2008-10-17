Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e3.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m9HFdbSK012420
	for <linux-mm@kvack.org>; Fri, 17 Oct 2008 11:39:37 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m9HFdb2c051460
	for <linux-mm@kvack.org>; Fri, 17 Oct 2008 11:39:37 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m9HFdbqr005631
	for <linux-mm@kvack.org>; Fri, 17 Oct 2008 11:39:37 -0400
Subject: Re: [PATCH 5/9] Restore memory address space
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <1224233070.2634.114.camel@frecb000730.frec.bull.fr>
References: <20081016181414.934C4FCC@kernel>
	 <20081016181421.3BA319FA@kernel>
	 <1224233070.2634.114.camel@frecb000730.frec.bull.fr>
Content-Type: text/plain
Date: Fri, 17 Oct 2008 08:39:34 -0700
Message-Id: <1224257974.1848.49.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nadia Derbey <Nadia.Derbey@bull.net>
Cc: containers <containers@lists.linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Linus Torvalds <torvalds@osdl.org>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>
List-ID: <linux-mm.kvack.org>

On Fri, 2008-10-17 at 10:44 +0200, Nadia Derbey wrote:
> On Thu, 2008-10-16 at 11:14 -0700, Dave Hansen wrote:
> > +static int cr_page_read(struct cr_ctx *ctx, struct page *page, char *buf)
> > +{
> > +	void *ptr;
> > +	int ret;
> > +
> > +	ret = cr_kread(ctx, buf, PAGE_SIZE);
> > +	if (ret < 0)
> > +		return ret;
> > +
> > +	ptr = kmap_atomic(page, KM_USER1);
> > +	memcpy(ptr, buf, PAGE_SIZE);
> > +	kunmap_atomic(page, KM_USER1);
> 
> Here too, I think this should be changed to 
> kunmap_atomic(ptr, KM_USER1);

Thanks, Nadia.

These fixes will show up in the git tree shortly:

http://git.kernel.org/gitweb.cgi?p=linux/kernel/git/daveh/linux-2.6-cr.git;a=summary

I just created it, so it may take a few moments for the gitweb script to
find it.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
